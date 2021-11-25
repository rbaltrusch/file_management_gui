classdef (Abstract) Widget < handle
    methods(Access = public, Static, Abstract)
        widget = create_widget(styler, varargin);
    end
end
