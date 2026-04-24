// Extracted from login_screen.dart so both the shell and auth sub-widgets
// can share these enum types without circular imports.

/// Defines the primary top-level views accessible via the Top Navigation Bar.
enum AppView { home, about, auth }

/// Defines the specific sub-states within the Authentication view.
enum AuthState { login, signup, success }
