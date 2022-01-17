#include <gtk/gtk.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <pwd.h>
#include <unistd.h>

void executeCMD(const char *cmd, char *result)   
{   
    char buf_ps[5000];   
    char ps[5000]={0};   
    FILE *ptr;   
    strcpy(ps, cmd);   
    if((ptr=popen(ps, "r"))!=NULL)   
    {   
        while(fgets(buf_ps, 5000, ptr)!=NULL)   
        {   
           strcat(result, buf_ps);   
           if(strlen(result)>5000)   
               break;   
        }   
        pclose(ptr);   
        ptr = NULL;   
    }   
    else  
    {   
        printf("popen %s error\n", ps);   
    }   
}  


void split_path_name(char *fullname, char* path, char* file) //split path and name
{
  int i=strlen(fullname);
  int j,flag=0;
  for (j=0;j<i;j++) if (fullname[j]=='/') flag=j;
  strcpy(path,fullname+7); path[flag-7]='\0';
  strcpy(file,fullname+flag+1);
}

void split_type(char *file, char *name, char *type) //split filename and type
{
  int i=strlen(file);
  int j,flag=0;
  for (j=0;j<i;j++) if (file[j]=='.') flag=j;
  strcpy(name,file); name[flag]='\0';
  strcpy(type,file+flag+1);
}
 
//GtkWidget *g_lbl_hello;
//GtkWidget *g_lbl_count;
GtkWidget *g_text_v;
GtkTextBuffer *buffer;
GtkTextIter start,end;
GtkImage *struct_image;

char filename[250];
char filename2[250];
char path2[250],file2[250],name2[250],type2[20];
char path1[250],file1[250],name1[250],type1[20];

//GtkWidget 
 
int main(int argc, char *argv[])
{
    GtkBuilder      *builder; 
    GtkWidget       *window;
 
    gtk_init(&argc, &argv);
 
    builder = gtk_builder_new();
    gtk_builder_add_from_file (builder, "glade_hello_world.glade", NULL);
 
    window = GTK_WIDGET(gtk_builder_get_object(builder, "window_main"));
    gtk_builder_connect_signals(builder, NULL);
    
    struct_image = GTK_WIDGET(gtk_builder_get_object(builder, "struct_image"));
    
    g_text_v = GTK_WIDGET(gtk_builder_get_object(builder, "text_v"));
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(g_text_v));
    gtk_text_buffer_set_text(buffer,"mkdir ~/Desktop/pppp",-1);
 
    g_object_unref(builder);
 
    gtk_widget_show(window);                
    gtk_main();
 
    return 0;
}
 
// called when button is clicked
void on_btn_hello_clicked()
{
    static unsigned int count = 0;
    char str_count2[100] = {0};
    
    gtk_text_buffer_get_bounds(GTK_TEXT_BUFFER(buffer),&start,&end);
    gchar *gtktext;
    gtktext=gtk_text_buffer_get_text(GTK_TEXT_BUFFER(buffer),&start,&end,FALSE);
    sprintf(str_count2,"%s",gtktext);
    printf("%s\n",str_count2);
    
    system(str_count2);
}

void on_filebutton_file_set(GtkFileChooser *filebutton)  //choose verilog
{
    printf("verilog selected\n");
    gchar *gfilename;
    gfilename = gtk_file_chooser_get_uri(GTK_FILE_CHOOSER(filebutton));
    sprintf(filename,"%s",gfilename);
   
    split_path_name(filename,path1,file1);
    printf("%s\n",filename);
    printf("path=%s file=%s\n",path1,file1);
    split_type(file1,name1,type1);
    printf("name=%s type=%s\n",name1,type1);
    if (strcmp(type1,"v")) {printf("not a verilog!\n");}
}

void on_filebutton2_file_set(GtkFileChooser *filebutton2)  //choose testbench
{
    printf("testbench selected\n");
    gchar *gfilename2;
    gfilename2 = gtk_file_chooser_get_uri(GTK_FILE_CHOOSER(filebutton2));
    sprintf(filename2,"%s",gfilename2);
    
    split_path_name(filename2,path2,file2);
    printf("%s\n",filename2);
    printf("path=%s file=%s\n",path2,file2);
    split_type(file2,name2,type2);
    printf("name=%s type=%s\n",name2,type2);
    if (strcmp(type2,"v")) {printf("not a verilog!\n");}
    
}

void on_btn_simple_clicked()
{
 char cmdline[500];
 char image_path[500];
 strcpy(image_path,"path/to/");
 if (strcmp(type1,"v")) 
  {printf("illegal verilog!\n");}
 else
 {
  strcpy(cmdline,"cd path/to/;");
  strcat(cmdline,"./simple2.sh ");
  strcat(cmdline,name1);
  strcat(cmdline," ");
  strcat(cmdline,path1);
  printf("cmdline= %s\n",cmdline);
  system(cmdline);
  //show image
  strcat(image_path,name1);
  strcat(image_path,".png");
  gtk_image_set_from_file(struct_image,image_path);
 }
}

void on_btn_simtest_clicked()
{
 char cmdline[500];
 if (strcmp(type2,"v")||strcmp(type1,"v")) 
  {printf("illegal verilog or testbench!\n");}
 else
 {
  strcpy(cmdline,"cd path/to/;");
  strcat(cmdline,"./simtest3.sh ");
  strcat(cmdline,name1);
  strcat(cmdline," ");
  strcat(cmdline,path1);
  strcat(cmdline," ");
  strcat(cmdline,name2);
  strcat(cmdline," ");
  strcat(cmdline,path2);
  printf("cmdline= %s\n",cmdline);
  system(cmdline);
  
  char cmdline2[500];
  char arg1[200];
  strcpy(cmdline2,"path/to/");
  strcat(cmdline2,name1);
  strcat(cmdline2,"_simtest.vcd");
  strcpy(arg1,name1);
  strcat(arg1,"_simtest");
  execl(cmdline2,arg1,NULL);
 }
}

// called when window is closed
void on_window_main_destroy()
{
    gtk_main_quit();
}


