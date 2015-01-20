# All views in <%= namespace.camelize %> will inherit from
# this common base class.
class <%= namespace.classify %>.Views.Base extends Lanes.Views.Base

    abstractClass: true
