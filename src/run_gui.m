%Runs the file management gui.
%
%Author: Richard Baltrusch
%Date: 25/11/2021

styler = gui.Styler();
builder = guilib.Builder(styler);
gui_ = gui.Gui(builder);
gui_.build();
