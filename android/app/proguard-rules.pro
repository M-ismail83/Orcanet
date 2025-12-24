# Fix for R8 missing class errors with Android Window (Foldable support)
-dontwarn androidx.window.**
-keep class androidx.window.** { *; }