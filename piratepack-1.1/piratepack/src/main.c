#include <gtk/gtk.h>
#include <stdio.h>
#include <string.h>
 
typedef struct _Data Data;
struct _Data
{
    /* Buffers that will display output */
    //GtkTextBuffer *out;
    //GtkTextBuffer *err;
 
    /* Progress bar that will be updated */

  GtkWindow *window;

  GtkTable *hbuttonbox;
  
  GtkProgressBar *progress;

  GtkLabel *message;

  GtkButton *button;
  GtkButton *button_remove;

  gchar *action;
 
    /* Timeout source id */
    gint timeout_id;
};
 
static void
cb_child_watch( GPid  pid,
                gint  status,
                Data *data )
{
    /* Remove timeout callback */
    g_source_remove( data->timeout_id );
 
    /* Close pid */
    g_spawn_close_pid( pid );
}
 
static gboolean
cb_out_watch( GIOChannel   *channel,
              GIOCondition  cond,
              Data         *data )
{
    gchar *string;
    gsize  size;
 
    if( cond == G_IO_HUP )
    {
        g_io_channel_unref( channel );
        return( FALSE );
    }
 
    g_io_channel_read_line( channel, &string, &size, NULL, NULL );
    //gtk_text_buffer_insert_at_cursor( data->out, string, -1 );
    g_free( string );
 
    return( TRUE );
}
 
static gboolean
cb_err_watch( GIOChannel   *channel,
              GIOCondition  cond,
              Data         *data )
{
    gchar *string;
    gsize  size;
 
    if( cond == G_IO_HUP )
    {
        g_io_channel_unref( channel );
        return( FALSE );
    }
 
    g_io_channel_read_line( channel, &string, &size, NULL, NULL );
    gtk_label_set_label( data->message, string);
    g_free( string );

    if (strcmp(data->action,"install")==0) {
      if (g_strcmp0("Installation Complete\n",gtk_label_get_label(data->message)) == 0) {

	gtk_container_remove(data->hbuttonbox,data->button);
	data->button = gtk_button_new_with_label( "Exit" );
	gtk_widget_set_size_request(data->button,120,-1);
	g_signal_connect( G_OBJECT( data->button ), "clicked",
			  G_CALLBACK( gtk_main_quit ), NULL );
	
	gtk_container_add(GTK_HBUTTON_BOX( data->hbuttonbox ),GTK_BUTTON( data->button ));
	gtk_widget_show(data->button);
      }
    }
    else if (strcmp(data->action,"reinstall")==0) {
      if (g_strcmp0("Reinstallation Complete\n",gtk_label_get_label(data->message)) == 0) {

        gtk_container_remove(data->hbuttonbox,data->button);
	gtk_container_remove(data->hbuttonbox,data->button_remove);
        data->button = gtk_button_new_with_label( "Exit" );
        gtk_widget_set_size_request(data->button,120,-1);
        g_signal_connect( G_OBJECT( data->button ), "clicked",
                          G_CALLBACK( gtk_main_quit ), NULL );

        gtk_container_add(GTK_HBUTTON_BOX( data->hbuttonbox ),GTK_BUTTON( data->button ));
        gtk_widget_show(data->button);
      }
    }
    else if (strcmp(data->action,"remove")==0) {
      if (g_strcmp0("Pirate Pack Removed\n",gtk_label_get_label(data->message)) == 0) {

        gtk_container_remove(data->hbuttonbox,data->button);
        gtk_container_remove(data->hbuttonbox,data->button_remove);
        data->button = gtk_button_new_with_label( "Exit" );
        gtk_widget_set_size_request(data->button,120,-1);
        g_signal_connect( G_OBJECT( data->button ), "clicked",
                          G_CALLBACK( gtk_main_quit ), NULL );

        gtk_container_add(GTK_HBUTTON_BOX( data->hbuttonbox ),GTK_BUTTON( data->button ));
        gtk_widget_show(data->button);
      }

    }

    return( TRUE );
}
 
static gboolean
cb_timeout( Data *data )
{
    /* Bounce progress bar */
    gtk_progress_bar_pulse( data->progress );
 
    return( TRUE );
}
 
static void
cb_execute( GtkButton *button,
            Data      *data)
{
 
    GPid        pid;
    gchar    *argv[3];

    argv[0] = "/usr/bin/piratepack";
    if (strcmp(data->action,"install") == 0) {
      argv[1] = "install";
      gtk_widget_set_sensitive(data->button,FALSE);
    }
    else if (strcmp(data->action,"reinstall") == 0) {
      argv[1] = "reinstall";
      gtk_widget_set_sensitive(data->button,FALSE);
      gtk_widget_set_sensitive(data->button_remove,FALSE);
    }
    else if (strcmp(data->action,"remove") == 0) {
      argv[1] = "remove";
      gtk_widget_set_sensitive(data->button,FALSE);
      gtk_widget_set_sensitive(data->button_remove,FALSE);
    }
    argv[2]=NULL;

    gint        out,
                err;
    GIOChannel *out_ch,
               *err_ch;
    gboolean    ret;
 
    /* Spawn child process */
    ret = g_spawn_async_with_pipes( NULL, argv, NULL,
                                    G_SPAWN_DO_NOT_REAP_CHILD, NULL,
                                    NULL, &pid, NULL, &out, &err, NULL );
    if( ! ret )
    {
        g_error( "SPAWN FAILED" );
        return;
    }
 
    /* Add watch function to catch termination of the process. This function
     * will clean any remnants of process. */
    g_child_watch_add( pid, (GChildWatchFunc)cb_child_watch, data );
 
    /* Create channels that will be used to read data from pipes. */
#ifdef G_OS_WIN32
    out_ch = g_io_channel_win32_new_fd( out );
    err_ch = g_io_channel_win32_new_fd( err );
#else
    out_ch = g_io_channel_unix_new( out );
    err_ch = g_io_channel_unix_new( err );
#endif
 
    /* Add watches to channels */
    g_io_add_watch( out_ch, G_IO_IN | G_IO_HUP, (GIOFunc)cb_out_watch, data );
    g_io_add_watch( err_ch, G_IO_IN | G_IO_HUP, (GIOFunc)cb_err_watch, data );
 
    /* Install timeout fnction that will move the progress bar */
    data->timeout_id = g_timeout_add( 100, (GSourceFunc)cb_timeout, data );
}

static void cb_execute_install( GtkButton *button,
				Data      *data)
{
 
  data->action = "install";
  cb_execute(button,data);

}

static void cb_execute_reinstall( GtkButton *button,
                                Data      *data)
{

  data->action = "reinstall";
  cb_execute(button,data);

}


static void cb_execute_remove( GtkButton *button,
				Data      *data)
{
  

  static GtkWidget *dialog = NULL;
  gint              response;


      GtkWidget *label;
      GtkWidget *box;
#if 1
      /* Create dialog */
      dialog = gtk_dialog_new();
 
      /* Set it modal and transient for main window. */
      gtk_window_set_modal( GTK_WINDOW( dialog ), TRUE );
      gtk_window_set_transient_for( GTK_WINDOW( dialog ),
      		    GTK_WINDOW( data->window ) );
 
      /* Set title */
      gtk_window_set_title( GTK_WINDOW( dialog ), "Confirmation" );
 
      /* Add buttons. */
      gtk_dialog_add_button( GTK_DIALOG( dialog ), GTK_STOCK_YES, 1 );
      gtk_dialog_add_button( GTK_DIALOG( dialog ), GTK_STOCK_NO,  2 );
#endif
      /* If we use convenience API function gtk_dialog_new_with_buttons,
       * last six function calls can be written as: */
#if 0
      dialog = gtk_dialog_new_with_buttons( "Confirmation",
					    GTK_WINDOW( window ),
					    GTK_DIALOG_MODAL,
					    GTK_STOCK_YES, 1,
					    GTK_STOCK_NO,  2,
					    NULL );
#endif
 
      /* Create label */
      label = gtk_label_new( "Remove Pirate Pack?" );
 
      /* Pack label, taking API change in account. */
#if GTK_MINOR_VERSION < 14
      box = GTK_DIALOG( dialog )->vbox;
#else
      box = gtk_dialog_get_content_area( GTK_DIALOG( dialog ) );
#endif
      gtk_box_pack_start( GTK_BOX( box ), label, TRUE, TRUE, 0 );
 
      /* Show dialog */
      gtk_widget_show_all( dialog );


  /* Run dialog */
  response = gtk_dialog_run( GTK_DIALOG( dialog ) );
  gtk_widget_destroy( dialog );

  if (response == 1) {
    data->action = "remove";                                                                                                                                                                                                                     cb_execute(button,data);
  }
}


int
install_pack( int    argc,
      char **argv )
{

  char *stderr_string;

  //start setup

  stderr_string = "Starting Installation";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  char *curpath = g_get_current_dir();
  char *homedir = g_get_home_dir();

  char *logpipe = malloc(2*strlen(homedir)+100);
  
  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  strcpy (logpipe,">> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_install.log 2>> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_install.log");

  char *str = malloc(2*strlen(homedir)+strlen(curpath)+100);

  strcpy (str,"echo \"[$(date)]\" ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+r piratepack");
  strcat (str,logpipe);
  system(str);

  chdir("piratepack");

  if (g_file_test("logs/.installed",G_FILE_TEST_IS_REGULAR)) {
    strcpy (str,"chmod -R u+rw logs/.installed ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf logs/.installed ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"touch logs/.installed ");
  strcat (str,logpipe);
  system(str);

  //install tor-browser

  stderr_string = "Installing tor-browser";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("tor-browser",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw tor-browser ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf tor-browser ");
    strcat (str,logpipe);
    system(str);
  }
  
  strcpy (str,"mkdir tor-browser ");
  strcat (str,logpipe);
  system(str);
  
  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/tor-browser/* ");
  strcat (str,logpipe);
  system(str);

  chdir("tor-browser");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/tor-browser/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_tor-browser.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_tor-browser.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo tor-browser >> logs/.installed 2>> logs/piratepack_install.log");

  //install firefox-mods

  stderr_string = "Installing firefox-mods";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("firefox-mods",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw firefox-mods ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf firefox-mods ");
    strcat (str,logpipe);
    system(str);
  }
  
  strcpy (str,"mkdir firefox-mods ");
  strcat (str,logpipe);
  system(str);
  
  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/firefox-mods/* ");
  strcat (str,logpipe);
  system(str);

  chdir("firefox-mods");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/firefox-mods/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_firefox-mods.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_firefox-mods.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo firefox-mods >> logs/.installed 2>> logs/piratepack_install.log");

  //install file-manager

  stderr_string = "Installing file-manager";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("file-manager",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw file-manager ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf file-manager ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"mkdir file-manager ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/file-manager/* ");
  strcat (str,logpipe);
  system(str);

  chdir("file-manager");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/file-manager/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_file-manager.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_file-manager.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo file-manager >> logs/.installed 2>> logs/piratepack_install.log");

  //install ppcavpn

  stderr_string = "Installing ppcavpn";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("ppcavpn",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw ppcavpn ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf ppcavpn ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"mkdir ppcavpn ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/ppcavpn/* ");
  strcat (str,logpipe);
  system(str);

  chdir("ppcavpn");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/ppcavpn/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_ppcavpn.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_ppcavpn.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo ppcavpn >> logs/.installed 2>> logs/piratepack_install.log");

  //install theme

  stderr_string = "Installing theme";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("theme",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw theme ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf theme ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"mkdir theme ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/theme/* ");
  strcat (str,logpipe);
  system(str);

  chdir("theme");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/theme/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_theme.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_theme.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo theme >> logs/.installed 2>> logs/piratepack_install.log");

  system("echo >> logs/.installed 2>> logs/piratepack_install.log");

  //complete installation

  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  if (g_file_test("piratepack/logs/.removed",G_FILE_TEST_IS_REGULAR)) {
    strcpy (str,"chmod u+rw piratepack/logs/.removed ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm piratepack/logs/.removed ");
    strcat (str,logpipe);
    system(str);
  }

  stderr_string = "Installation Complete";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );
 
  return( 0 );
}

int
reinstall_pack( int    argc,
      char **argv )
{

  char *stderr_string;

  //start setup

  stderr_string = "Reinstalling";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  char *curpath = g_get_current_dir();
  char *homedir = g_get_home_dir();

  char *logpipe = malloc(2*strlen(homedir)+100);
  
  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  strcpy (logpipe,">> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_remove.log 2>> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_remove.log");

  char *str = malloc(2*strlen(homedir)+strlen(curpath)+100);

  strcpy (str,"echo \"[$(date)]\" ");
  strcat (str,logpipe);
  system(str);

  if (g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod u+r piratepack ");
    strcat (str,logpipe);
    system(str);

    chdir("piratepack");

    char line[100];
    FILE *fp;
    fp = fopen("logs/.installed", "r");
    if(!fp) return 1;

    while(fgets(line,sizeof(line),fp) != NULL) {

      int len = strlen(line)-1;
      if(line[len] == '\n') 
	line[len] = 0;

      if (g_file_test(line,G_FILE_TEST_IS_DIR)) {

	strcpy (str,"Removing ");
        strcat (str,line);
	sleep( 1 );
	fprintf( stderr, "%s\n", str );
	
	strcpy (str,"chmod u+rx ");
	strcat (str,line);
	strcat (str," ");
	strcat (str,logpipe);
	system(str);

	chdir(line);

	strcpy (str,"chmod u+rx remove_");
	strcat (str,line);
	strcat (str,".sh ");
        strcat (str,logpipe);
        system(str);

	strcpy (str,"./remove_");
        strcat (str,line);
	strcat (str,".sh ");
        strcat (str,logpipe);
        system(str);

	chdir("../");

	if (g_file_test(line,G_FILE_TEST_IS_DIR)) {
	
	  strcpy (str,"chmod u+rw ");
	  strcat (str,line);
	  strcat (str," ");
	  strcat (str,logpipe);
	  system(str);

	  strcpy (str,"rm -rf ");
	  strcat (str,line);
	  strcat (str," ");
	  strcat (str,logpipe);
	  system(str);
	}
	
      }

    }
    fclose(fp);
    chdir(homedir);
  }

  //complete removal

  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  strcpy (str,"touch piratepack/logs/.removed ");
  strcat (str,logpipe);
  system(str);

  if (g_file_test("piratepack/logs/.installed",G_FILE_TEST_IS_REGULAR)) {
    strcpy (str,"chmod u+rw piratepack/logs/.installed ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm piratepack/logs/.installed ");
    strcat (str,logpipe);
    system(str);
  }

  //Start Install

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  strcpy (logpipe,">> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_install.log 2>> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_install.log");

  strcpy (str,"echo \"[$(date)]\" ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+r piratepack");
  strcat (str,logpipe);
  system(str);

  chdir("piratepack");

  if (g_file_test("logs/.installed",G_FILE_TEST_IS_REGULAR)) {
    strcpy (str,"chmod -R u+rw logs/.installed ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf logs/.installed ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"touch logs/.installed ");
  strcat (str,logpipe);
  system(str);

  //install tor-browser

  stderr_string = "Installing tor-browser";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("tor-browser",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw tor-browser ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf tor-browser ");
    strcat (str,logpipe);
    system(str);
  }
  
  strcpy (str,"mkdir tor-browser ");
  strcat (str,logpipe);
  system(str);
  
  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/tor-browser/* ");
  strcat (str,logpipe);
  system(str);

  chdir("tor-browser");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/tor-browser/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_tor-browser.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_tor-browser.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo tor-browser >> logs/.installed 2>> logs/piratepack_install.log");

  //install firefox-mods

  stderr_string = "Installing firefox-mods";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("firefox-mods",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw firefox-mods ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf firefox-mods ");
    strcat (str,logpipe);
    system(str);
  }
  
  strcpy (str,"mkdir firefox-mods ");
  strcat (str,logpipe);
  system(str);
  
  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/firefox-mods/* ");
  strcat (str,logpipe);
  system(str);

  chdir("firefox-mods");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/firefox-mods/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_firefox-mods.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_firefox-mods.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo firefox-mods >> logs/.installed 2>> logs/piratepack_install.log");

  //install file-manager

  stderr_string = "Installing file-manager";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("file-manager",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw file-manager ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf file-manager ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"mkdir file-manager ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/file-manager/* ");
  strcat (str,logpipe);
  system(str);

  chdir("file-manager");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/file-manager/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_file-manager.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_file-manager.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo file-manager >> logs/.installed 2>> logs/piratepack_install.log");

  //install ppcavpn

  stderr_string = "Installing ppcavpn";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("ppcavpn",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw ppcavpn ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf ppcavpn ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"mkdir ppcavpn ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/ppcavpn/* ");
  strcat (str,logpipe);
  system(str);

  chdir("ppcavpn");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/ppcavpn/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_ppcavpn.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_ppcavpn.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo ppcavpn >> logs/.installed 2>> logs/piratepack_install.log");

  //install theme

  stderr_string = "Installing theme";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  if (g_file_test("theme",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod -R u+rw theme ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm -rf theme ");
    strcat (str,logpipe);
    system(str);
  }

  strcpy (str,"mkdir theme ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod -R u+r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/theme/* ");
  strcat (str,logpipe);
  system(str);

  chdir("theme");

  strcpy (str,"cp -r ");
  strcat (str,"/usr/lib/piratepack");
  strcat (str,"/setup/theme/* . ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"chmod u+x install_theme.sh ");
  strcat (str,logpipe);
  system(str);

  strcpy (str,"./install_theme.sh ");
  strcat (str,logpipe);
  system(str);

  chdir("../");

  system("echo theme >> logs/.installed 2>> logs/piratepack_install.log");

  system("echo >> logs/.installed 2>> logs/piratepack_install.log");

  //complete installation

  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  if (g_file_test("piratepack/logs/.removed",G_FILE_TEST_IS_REGULAR)) {
    strcpy (str,"chmod u+rw piratepack/logs/.removed ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm piratepack/logs/.removed ");
    strcat (str,logpipe);
    system(str);
  }

  stderr_string = "Reinstallation Complete";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );
 
  return( 0 );
}

int
remove_pack( int    argc,
      char **argv )
{

  char *stderr_string;

  //start removal

  stderr_string = "Removing Pirate Pack";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  char *curpath = g_get_current_dir();
  char *homedir = g_get_home_dir();

  char *logpipe = malloc(2*strlen(homedir)+100);

  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  strcpy (logpipe,">> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_remove.log 2>> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_remove.log");

  char *str = malloc(strlen(homedir)+strlen(curpath)+100);

  strcpy (str,"echo \"[$(date)]\" ");
  strcat (str,logpipe);
  system(str);

  if (g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {

    strcpy (str,"chmod u+r piratepack ");
    strcat (str,logpipe);
    system(str);

    chdir("piratepack");

    char line[100];
    FILE *fp;
    fp = fopen("logs/.installed", "r");
    if(!fp) return 1;

    while(fgets(line,sizeof(line),fp) != NULL) {

      int len = strlen(line)-1;
      if(line[len] == '\n') 
	line[len] = 0;

      if (g_file_test(line,G_FILE_TEST_IS_DIR)) {

	strcpy (str,"Removing ");
        strcat (str,line);
	sleep( 1 );
	fprintf( stderr, "%s\n", str );
	
	strcpy (str,"chmod u+rx ");
	strcat (str,line);
	strcat (str," ");
	strcat (str,logpipe);
	system(str);

	chdir(line);

	strcpy (str,"chmod u+rx remove_");
	strcat (str,line);
	strcat (str,".sh ");
        strcat (str,logpipe);
        system(str);

	strcpy (str,"./remove_");
        strcat (str,line);
	strcat (str,".sh ");
        strcat (str,logpipe);
        system(str);

	chdir("../");

	if (g_file_test(line,G_FILE_TEST_IS_DIR)) {
	
	  strcpy (str,"chmod u+rw ");
	  strcat (str,line);
	  strcat (str," ");
	  strcat (str,logpipe);
	  system(str);

	  strcpy (str,"rm -rf ");
	  strcat (str,line);
	  strcat (str," ");
	  strcat (str,logpipe);
	  system(str);
	}
	
      }

    }
    fclose(fp);
    chdir(homedir);
  }

  //complete removal

  chdir(homedir);

  if (!g_file_test("piratepack",G_FILE_TEST_IS_DIR)) {
    system("mkdir piratepack >> .piratepack.temp 2>> .piratepack.temp");
    chdir("piratepack");
    if (!g_file_test("logs",G_FILE_TEST_IS_DIR)) {
      system("mkdir logs >> .piratepack.temp 2>> .piratepack.temp");
    }
    chdir(homedir);
  }

  strcpy (str,"touch piratepack/logs/.removed ");
  strcat (str,logpipe);
  system(str);

  if (g_file_test("piratepack/logs/.installed",G_FILE_TEST_IS_REGULAR)) {
    strcpy (str,"chmod u+rw piratepack/logs/.installed ");
    strcat (str,logpipe);
    system(str);

    strcpy (str,"rm piratepack/logs/.installed ");
    strcat (str,logpipe);
    system(str);
  }

  stderr_string = "Pirate Pack Removed";
  sleep( 1 );
  fprintf( stderr, "%s\n", stderr_string );

  return( 0 );
}

int
open_pirate_file( int    argc,
	     char **argv )
{

  char *curpath = g_get_current_dir();
  char *homedir = g_get_home_dir();

  char *logpipe = malloc(2*strlen(homedir)+200);

  chdir(homedir);

  if (!g_file_test("piratepack/logs/.installed",G_FILE_TEST_IS_REGULAR)) {
    return ( 0 );
  }

  strcpy (logpipe,">> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_open.log 2>> ");
  strcat (logpipe,homedir);
  strcat (logpipe,"/piratepack/logs/piratepack_open.log");

  chdir("piratepack");

  char *file = argv[2];

  char *str = malloc(2*strlen(homedir)+2*strlen(file)+200);

  strcpy (str,"echo \"[$(date)]\" ");
  strcat (str,logpipe);
  system(str);

  if (!g_file_test("tmp",G_FILE_TEST_IS_DIR)) {
    strcpy(str,"mkdir tmp ");
    strcat(str,logpipe);
    system(str);

    strcpy(str,"chmod u+rwx tmp ");
    strcat(str,logpipe);
    system(str);
  }

  chdir(curpath);

  strcpy(str,"cp ");
  strcat(str,file);
  strcat(str," ~/piratepack/tmp ");
  strcat(str,logpipe);
  system(str);

  chdir(homedir);
  chdir("piratepack/tmp");
  
  strcpy(str,"chmod u+rx ../file-manager/install_file.sh ");
  strcat(str,logpipe);
  system(str);

  strcpy(str,"../file-manager/install_file.sh $(find *.pirate) ");
  strcat(str,logpipe);
  system(str);

  return( 0 );

}

 
int
main( int    argc,
      char **argv )
{

  if (argc > 1) {
    if (strcmp(argv[1],"install")==0) {
      return install_pack(argc,argv);
    }
    else if (strcmp(argv[1],"reinstall")==0) {
      return reinstall_pack(argc,argv);
    }
    else if (strcmp(argv[1],"remove")==0) {
      return remove_pack(argc,argv);
    }
    else if (strcmp(argv[1],"--pirate")==0) {
      return open_pirate_file(argc,argv);
    }
  }


  GtkWidget *window, *table1, *table2, *button, *progress, *text, *message, *logo, *hbuttonbox, *button_remove;
  Data *data;



    data = g_slice_new( Data );
 
    gtk_init( &argc, &argv );
 
    window = gtk_window_new( GTK_WINDOW_TOPLEVEL );
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
    gtk_window_set_default_size( GTK_WINDOW( window ), 500, 400 );
    gtk_window_set_title( GTK_WINDOW( window ), "Pirate Pack");
    gtk_window_set_icon_from_file( GTK_WINDOW( window ), "/usr/lib/piratepack/graphics/logo.png", NULL);
    
    g_signal_connect( G_OBJECT( window ), "destroy",
                      G_CALLBACK( gtk_main_quit ), NULL );

    table1 = gtk_table_new( 4, 3, FALSE );
    gtk_container_add( GTK_CONTAINER( window ), table1 );
      
    table2 = gtk_table_new( 3, 3, FALSE );
    gtk_table_attach( GTK_TABLE( table1 ), table2, 1, 2, 0, 1,
                      GTK_EXPAND | GTK_FILL, GTK_EXPAND | GTK_FILL, 0, 0 );

    logo = gtk_image_new_from_file("/usr/lib/piratepack/graphics/logo.png");
    gtk_table_attach( GTK_TABLE( table2 ), logo, 1, 2, 1, 2,
                      GTK_EXPAND | GTK_FILL, GTK_EXPAND | GTK_FILL, 5, 5 );

    message = gtk_label_new("The Pirate Pack enhances your digital freedom.\nGet the latest version at www.piratelinux.org");
    gtk_label_set_justify(message,GTK_JUSTIFY_CENTER);
    gtk_widget_set_size_request(message,-1,80);
    gtk_misc_set_alignment(message,0.5,1);
    gtk_table_attach( GTK_TABLE( table1 ), message, 1, 2, 1, 2,
                      GTK_EXPAND | GTK_FILL, GTK_EXPAND | GTK_FILL, 5, 5 );


    progress = gtk_progress_bar_new();
    gtk_table_attach( GTK_TABLE( table1 ),progress, 1, 2, 2, 3,
                      GTK_FILL, GTK_SHRINK | GTK_FILL, 5, 0 );

    //check if piratepack is installed
    char *homedir = g_get_home_dir();
    char *str = malloc(strlen(homedir)+100);
    strcpy (str,homedir);
    strcat (str,"/piratepack/logs/.installed");

    hbuttonbox = gtk_hbutton_box_new();
   
    if (g_file_test(str,G_FILE_TEST_IS_REGULAR)) {
      button = gtk_button_new_with_label( "Reinstall" );
      gtk_widget_set_size_request(button,120,-1);
      g_signal_connect( G_OBJECT( button ), "clicked",
			G_CALLBACK( cb_execute_reinstall ), data );
      button_remove = gtk_button_new_with_label( "Remove" );
      gtk_widget_set_size_request(button_remove,120,-1);
      g_signal_connect( G_OBJECT( button_remove ), "clicked",
			G_CALLBACK( cb_execute_remove ), data );
      gtk_container_add(GTK_HBUTTON_BOX( hbuttonbox ),GTK_BUTTON( button ));
      gtk_container_add(GTK_HBUTTON_BOX( hbuttonbox ),GTK_BUTTON( button_remove ));
      data->button_remove = GTK_BUTTON( button_remove );
    }
    else {
      button = gtk_button_new_with_label( "Install" );
      gtk_widget_set_size_request(button,120,-1);
      g_signal_connect( G_OBJECT( button ), "clicked",
			G_CALLBACK( cb_execute_install ), data );
      gtk_container_add(GTK_HBUTTON_BOX( hbuttonbox ),GTK_BUTTON( button ));
    }
    
    gtk_table_attach( GTK_TABLE( table1 ), GTK_HBUTTON_BOX( hbuttonbox ), 1, 2, 3, 4,
                      0, 0, 5, 5 );

    data->message = GTK_LABEL( message );
    data->progress = GTK_PROGRESS_BAR( progress );
    data->button = GTK_BUTTON( button );
    data->hbuttonbox = GTK_HBUTTON_BOX( hbuttonbox );
    data->window = GTK_WINDOW( window );

    gtk_widget_show_all( window );
 
    gtk_main();
 
    g_slice_free( Data, data );
 
    return( 0 );
}
