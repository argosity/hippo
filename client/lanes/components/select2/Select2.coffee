class Lanes.Components.Select2 extends Lanes.Components.Base

    writeTemplate: ->
        multiple = if this.multiple then "multiple" else ""
        "<div><select class='form-control' #{multiple} name='#{this.field_name}' data-hook='choices-input'></select></div>"

    readTemplate: ->
        "<div class='ro-input' name='#{this.field_name}'></div>"
