describe 'Essence.Views.Timelet', ->
  beforeEach ->
    @model = new Essence.Models.Timelet
      id: 123
      name: 'My test Timelet'
      duration: 33

    @collection = new Essence.Collections.Timelets [@model]
    @model.collection = @collection

    @view = new Essence.Views.Timelet model: @model
    @html = @view.render().$el

    setFixtures @html

  describe '#constructor', ->
    it 'creates an item view', ->
      expect(@view).toBeAnInstanceOf Backbone.Marionette.ItemView

    it 'sets the model', ->
      expect(@view.model).toBe @model

  describe '#initialize', ->
    it 'renders the state when the timelets is loaded', ->
      stub = sinon.stub @view, 'applyLoadedState'
      @view.initialize()
      @model.trigger 'loaded'
      expect(stub).toHaveBeenCalled()
      stub.restore()

    it 'renders the state when the timelets is unloaded', ->
      stub = sinon.stub @view, 'applyLoadedState'
      @view.initialize()
      @model.trigger 'unloaded'
      expect(stub).toHaveBeenCalled()
      stub.restore()

    it 'marks invalid fields on validation error', ->
      stub = sinon.stub @view, 'markValidationErrors'
      @view.initialize()
      @model.trigger 'invalid'
      expect(stub).toHaveBeenCalled()
      stub.restore()

    it 'collapses the Timelet when the collection is collapsed', ->
      stub = sinon.stub @view, 'collapse'
      @view.initialize()
      @model.collection.trigger 'collapse'
      expect(stub).toHaveBeenCalled()
      stub.restore()

  describe '#render', ->
    it 'renders the model', ->
      expect(@view.ui.fields).toHaveValue 'My test Timelet'

    it 'renders a delete button', ->
      expect(@html).toContain '.button.delete'

    it 'renders a load button', ->
      expect(@html).toContain '.button.load'

    it 'renders the loaded state', ->
      expect(@view.$el).not.toHaveClass 'loaded'
      @model.state.loaded = true
      @view.render()
      expect(@view.$el).toHaveClass 'loaded'

  describe '#updateModel', ->
    beforeEach ->
      @event = new jQuery.Event()
      @setStub = sinon.stub @model, 'setFromInputElement'

    afterEach ->
      @setStub.restore()

    it 'sets the attribute', ->
      @view.updateModel @event
      expect(@setStub).toHaveBeenCalled()

    describe 'with a valid model and changed values', ->
      beforeEach ->
        @model.set duration: 5

      it 'enables the save button', ->
        spy = sinon.spy @view, 'enableSaveButton'
        @view.updateModel @event
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe 'without changed values', ->
      it 'disables the save button', ->
        spy = sinon.spy @view, 'disableSaveButton'
        @view.updateModel @event
        expect(spy).toHaveBeenCalled()
        spy.restore()

    describe 'with an invalid model', ->
      beforeEach ->
        @model.set duration: 'abc'

      it 'disables the save button', ->
        spy = sinon.spy @view, 'disableSaveButton'
        @view.updateModel @event
        expect(spy).toHaveBeenCalled()
        spy.restore()

  describe '#expand', ->
    it 'makes the details visible', ->
      @view.ui.details.hide()
      @view.expand()
      expect(@view.ui.details).toBeVisible()

    it 'collapses all timelets in the collection', ->
      spy = sinon.spy @collection, 'trigger'
      @view.expand()
      expect(spy).toHaveBeenCalledWith 'collapse'
      spy.restore()

    it 'sets the expanded state', ->
      expect(@view.expanded).toBeFalsy()
      @view.expand()
      expect(@view.expanded).toBeTruthy()

    describe 'with an already expanded timelet', ->
      beforeEach ->
        @view.expanded = true

      it 'does nothing', ->
        spy = sinon.spy @collection, 'trigger'
        @view.expand()
        expect(spy).not.toHaveBeenCalled()
        spy.restore()

  describe '#collapse', ->
    beforeEach ->
      @view.expanded = true

    it 'hides the details', ->
      @view.ui.details.show()
      expect(@view.ui.details).toBeVisible()
      @view.collapse()
      expect(@view.ui.details).not.toBeVisible()

    it 'sets the expanded state', ->
      @view.expanded = true
      expect(@view.expanded).toBeTruthy()
      @view.collapse()
      expect(@view.expanded).toBeFalsy()

    describe 'with an already collapsed Timelet', ->
      beforeEach ->
        @view.expanded = false

      it 'does nothing', ->
        @view.collapse()
        expect(@view.expanded).toBeFalsy()

  describe '#delete', ->
    it 'destroys the model', ->
      spy = sinon.spy @model, 'destroy'
      @view.delete()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe '#enableSaveButton', ->
    beforeEach ->
      @view.ui.save.hide()

    it 'shows the save button', ->
      expect(@view.ui.save).not.toBeVisible()
      @view.enableSaveButton()
      expect(@view.ui.save).toBeVisible()

    it 'removes validation error marking', ->
      spy = sinon.spy @view, 'unmarkValidationErrors'
      @view.enableSaveButton()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe '#disableSaveButton', ->
    beforeEach ->
      @view.ui.save.show()

    it 'shows the save button', ->
      expect(@view.ui.save).toBeVisible()
      @view.disableSaveButton()
      expect(@view.ui.save).not.toBeVisible()

  describe '#save', ->
    it 'saves the model', ->
      spy = sinon.spy @model, 'save'
      @view.save()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    it 'disables the save button', ->
      spy = sinon.spy @view, 'disableSaveButton'
      @view.save()
      expect(spy).toHaveBeenCalled()
      spy.restore()

  describe '#markValidationErrors', ->
    it 'adds validation errors to fields', ->
      expect(@view.$el.find('input[name=duration]')).not.toHaveClass 'validation-error'
      @view.markValidationErrors @model, duration: 'too short'
      expect(@view.$el.find('input[name=duration]')).toHaveClass 'validation-error'

  describe '#unmarkValidationErrors', ->
    beforeEach ->
      @view.$el.find('input[name=duration]').addClass 'validation-error'

    it 'removes validation errors from fields', ->
      expect(@view.$el.find('input[name=duration]')).toHaveClass 'validation-error'
      @view.unmarkValidationErrors @model, duration: 'too short'
      expect(@view.$el.find('input[name=duration]')).not.toHaveClass 'validation-error'

  describe '#load', ->
    it 'triggers the load event', ->
      spy = sinon.spy @view, 'trigger'
      @view.load()
      expect(spy).toHaveBeenCalledWith 'timelet:load'
      spy.restore()

    it 'navigates to route for the this timelet', ->
      @view.load()
      expect(@navigation).toHaveBeenCalledWith "/timelet/#{ @model.id }"

    describe 'when the timelet is already loaded', ->
      beforeEach ->
        @model.state.loaded = true

      it 'does nothing', ->
        @view.load()
        expect(@navigation).not.toHaveBeenCalled()

  describe '#applyLoadedState', ->
    describe 'with a loaded timelet', ->
      beforeEach ->
        @model.state.loaded = true
        @view.$el.removeClass 'loaded'

      it 'sets the loaded class to the entire view', ->
        @view.applyLoadedState()
        expect(@view.$el).toHaveClass 'loaded'

    describe 'with an unloaded timelet', ->
      beforeEach ->
        @model.state.loaded = false
        @view.$el.addClass 'loaded'

      it 'removes the running class from the view', ->
        @view.applyLoadedState()
        expect(@view.$el).not.toHaveClass 'loaded'
