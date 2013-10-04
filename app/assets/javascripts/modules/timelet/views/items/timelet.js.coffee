# A single timelet view.
#
class Essence.Views.Timelet extends Backbone.Marionette.ItemView
  template: 'modules/timelet/templates/timelet'
  tagName: 'li'

  ui:
    details:    '.details'
    label:      '.label'
    save:       '.save'
    attributes: '[data-attribute]'

  events:
    'click .delete'  : 'delete'
    'click .load'    : 'load'
    'click .name'    : 'open'
    'click .close'   : 'close'
    'click .save'    : 'save'
    'blur .editable' : 'updateValue'

  initialize: ->
    @listenTo @model, 'change:loaded', @render
    @listenTo @model.collection, 'close', @close
    @listenTo @model, 'invalid', @markValidationErrors

  # Updates the model attribute with the corresponding field value.
  #
  # @param [jQuery.Event] event the click event
  #
  updateValue: (event) =>
    el = $(event.currentTarget)
    attribute = el.data 'attribute'

    return unless @model.has attribute

    @model.setStrict attribute, el.text()
    if @model.hasChanged(attribute) and @model.isValid()
      @enableSaveButton()
    else
      @disableSaveButton()

  # Shows or hides details of the timelet.
  #
  open: ->
    return if @model.expanded
    else
      @model.collection.trigger 'close'
      @model.expanded = true
      @ui.details.slideDown()
      @ui.label.attr 'contentEditable', 'true'
      @ui.label.addClass 'editing'

  # Hides details of the timelet.
  #
  close: ->
    delete @model.expanded
    @ui.label.removeAttr 'contentEditable'
    @ui.label.removeClass 'editing'
    @ui.details.slideUp()

  # Deletes the timelet from the collection.
  #
  delete: -> @model.destroy()

  # Enables the save button.
  #
  enableSaveButton: ->
    @ui.save.fadeIn()
    @unmarkValidationErrors()

  disableSaveButton: -> @ui.save.fadeOut()

  # Saves the timelet.
  #
  save: ->
    @model.save()
    @ui.save.fadeOut()

  unmarkValidationErrors: ->
    @ui.attributes.removeClass 'validation-error'

  markValidationErrors: (model, errors) =>
    for attribute, error of errors
      @$el.find("[data-attribute=#{ attribute }]").addClass 'validation-error'

  # Sets the current timelet as the active one.
  #
  load: ->
    return if @model.isLoaded()
    @trigger 'timelet:load'
    Backbone.history.navigate "/timelet/#{ @model.id }"
