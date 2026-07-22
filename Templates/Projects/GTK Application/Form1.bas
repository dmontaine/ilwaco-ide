	#include once "gtk/gtk.bi"

Sub on_button_clicked cdecl (ByVal widget As GtkWidget Ptr, ByVal user_data As gpointer)
	Print "Hello, World!"
End Sub

	Dim As GtkWidget Ptr win
	Dim As GtkWidget Ptr button
	Dim As GtkWidget Ptr box
	
	
	gtk_container_add(GTK_CONTAINER(win), box)
	gtk_window_set_title(GTK_WINDOW(win), "Hello World")
	gtk_window_set_default_size(GTK_WINDOW(win), 200, 200)
	
	button = gtk_button_new_with_label("Click Me")
	g_signal_connect(button, "clicked", G_CALLBACK(@on_button_clicked), NULL)
	
End Sub
