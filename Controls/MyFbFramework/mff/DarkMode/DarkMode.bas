
#include "DarkMode.bi"


Sub SetDarkMode(useDark As Boolean, fixDarkScrollbar_ As Boolean)
			Dim As GValue bValue
			g_value_init_(@bValue, G_TYPE_BOOLEAN)
			g_value_set_boolean(@bValue, useDark)
			g_object_set_property(G_OBJECT(gtk_settings_get_default()), "gtk-application-prefer-dark-theme", @bValue)
			g_value_unset(@bValue)
			g_darkModeEnabled = useDark
End Sub
