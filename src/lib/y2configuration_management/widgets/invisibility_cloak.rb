# Copyright (c) [2019] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "cwm"

module Y2ConfigurationManagement
  module Widgets
    # Widgets that can become invisible via the {visible=} method.
    # TODO: the value is discarded; check how it feels, maybe we want to save/restore it.
    module VisibilitySwitching
      EMPTY_WIDGET = CWM::Empty.new("ic_empty")

      attr_reader :visible

      def initialize_visibility_switching
        @visible = true
      end

      def visible=(visible)
        return if @visible == visible
        @visible = visible
        if visible
          replace(@inner)
        else
          replace(EMPTY_WIDGET)
        end
      end
    end

    # Salt forms specific visibility switching
    module InvisibilityCloak
      include VisibilitySwitching

      # @return [FormCondition,nil]
      attr_reader :visible_if

      def initialize_invisibility_cloak(visible_if)
        initialize_visibility_switching
        @visible_if = visible_if
      end

      # Automatic invisibility: when the form controller asks us,
      # we evaluate a condition and update our visibility
      # @param data [FormData]
      def update_visibility(data)
        return unless @visible_if
        self.visible = @visible_if.evaluate(data)
      end
    end
  end
end
