# Copyright (c) [2018] SUSE LLC
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

require "yast"
require "cwm"
require "cwm/dialog"

# @!macro [new] seeDialog
#   @see http://www.rubydoc.info/github/yast/yast-yast2/CWM/Dialog:${0}
# @!macro [new] seeAbstractWidget
#   @see http://www.rubydoc.info/github/yast/yast-yast2/CWM/AbstractWidget:${0}
module Y2ConfigurationManagement
  module Salt
    # This class runs a dialog for selecting the Salt Formulas that will
    # be configured and applied to the current system.
    class FormulaSelection < CWM::Dialog
      # @return [Array<Formula>] available formulas
      attr_reader :formulas

      # Constructor
      #
      # @param formulas [Array<Formula>]
      def initialize(formulas)
        textdomain "configuration_management"
        @formulas = formulas
      end

      # @macro seeDialog
      def title
        _("Formulas")
      end

      # @macro seeDialog
      def contents
        VBox(
          HelpWidget.new,
          VSpacing(1.0),
          Frame(
            _("Choose which formulas to apply:"),
            VBox(
              *formulas.map { |f| Left(FormulaSelect.new(f)) }
            )
          ),
          VStretch()
        )
      end

      # @macro seeDialog
      def disable_buttons
        ["back_button"]
      end

      # Class for adding a help text to the dialog
      class HelpWidget < CWM::CustomWidget
        # @macro seeAbstractWidget
        def help
          _("Select which formulas you want to apply to this machine. "\
            "For each selected formula, you will be able to customize it "\
            "with parameters")
        end

        # @macro seeAbstractWidget
        def contents
          Empty()
        end
      end

      # This class represents a CheckBox for enabling a specific Salt Formula
      class FormulaSelect < CWM::CheckBox
        attr_reader :formula

        # Constructor
        #
        # @param [Formula]
        # @macro seeAbstractWidget
        def initialize(formula)
          textdomain "configuration_management"

          @formula = formula
          self.widget_id = "formula_select:#{formula.name}"
        end

        # @macro seeAbstractWidget
        def label
          "#{formula.name}: #{formula.description}"
        end

        # @macro seeAbstractWidget
        def init
          self.value = !!formula.enabled?
        end

        # Enable or disable depending on the CheckBox value
        #
        # @macro seeAbstractWidget
        def store
          formula.enabled = value
        end
      end
    end
  end
end
