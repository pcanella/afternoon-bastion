//TODO: Add App.$isEditing = false when exiting the locations page. Some sort of handler or listener thingy

var locations = t.Locations;
App = Ember.Application.create({
    $isEditing: false,
    $isCreating: false,
    $isDeleting: false,
    $test: '',
    rootElement: '#test'
});

App.Router.map(function() {
    this.resource('locations', function() {
        this.resource('location', { path: ':slug' });
    });
});

App.LocationsRoute = Ember.Route.extend({
    model: function() {
      // Set to false every time, to re-initiate "edit"
        $(document).on('hidden.bs.modal', function() {
            console.log('repainting modal...');
            App.$isEditing = false;
            App.$isCreating = false;
            App.$isDeleting = false;
            // Every time modal comes, this field is reset
            $('.modal-loc-title').html('');
            $('.modal-body').html('');
            $('.option-confirm').text('');
            $('.btn-default').next().removeAttr('class').addClass('option-confirm btn');
        });
        return locations;
    }
});

App.LocationRoute = Ember.Route.extend({
  model: function(params) {
    return locations.findBy('slug', params.slug);
  }
});

App.LocationsController = Ember.ArrayController.extend({
  actions: {
      // Resets modal to "default"
      initModal: function() {

      },

      openNew: function(info) {
        App.$isCreating = true;
        App.LocationsController.prototype._actions.initModal();
        $('#optionsModal').modal();


      },

    openEdit: function(info) {
         window.location.href = 'allLocations#/locations/' + info.slug;
          $('#optionsModal').modal();
          var t = $('.edit_location_form').clone();
          console.log(t);
  setTimeout(function() {
         $('.modal-body').append($('.edit_location_form').html());
         App.$isEditing = true;
          },100);



        
        

          $('.option-confirm').addClass('btn-success').append('Complete Edit');
          $('.option-confirm').on('click', function() {
    
            setTimeout(function(){
            App.LocationController.prototype._actions.ajaxCall();

            }, 800);       

        });

    },


      openDelete: function(info) {
        App.$isDeleting = true;
        //App.LocationsController.initModal();
        var open;
        $('#optionsModal').on('hidden.bs.modal', function() {
          // Every time modal comes, this field is reset
          $('.modal-loc-title, .option-confirm').html('');
        });

        var overlay = $('<div id="overlay"></div>'),
        self = this;
        //overlay.appendTo(document.body)
        $('.option-confirm').addClass('btn-danger delete_certain');
        var messageBox = $('<div class="delete-olay">Are you sure you want to delete the <strong>' + info.title + '</strong> location? You cannot undo this!</div>');
        $('.option-confirm').append('Yes, Delete This Location');
        $('.modal-loc-title').append('Delete ' + info.title);
        $('.modal-body').append(messageBox);
        $('#optionsModal').modal();

        $('.delete_certain').on('click', function() {
          App.LocationsController.prototype._actions.ajaxDelete(info);
          $('.delete-success').removeClass('hide');
          $('.olay-' + info.slug).fadeOut('slow', function() {
             this.remove();
          });
        });
      },

        ajaxDelete: function(params) {
          var unparsed = {'_id': params._id, 'slug': params.slug, 'action': 'delete'};
      $.ajax({
              url: '/location',
              type: 'POST',
              data: unparsed,
              processData: true,
              //contentType: "application/json; charset=utf-8",
              //dataType: "json",
              success: function(data, textStatus, jqXHR)
              {
                  console.log('Successfully deleted!');
                   $('#optionsModal').modal('hide');
                   //$('.delete-success').css('display", "block !important');
              },
              error: function(jqXHR, textStatus, errorThrown)
              {
                console.error('Some dumb error occurred');
                $('#optionsModal').modal('hide');
                console.error(errorThrown);
                console.log(jqXHR);
              }
          });
      console.log(params._id);
    }
  }
});

App.LocationController = Ember.ObjectController.extend({
  actions: {
      ajaxCall: function() {
        var self = this;
        var $inputs = $('#edit_form :input');
        var values = {};
        $inputs.each(function() {
            //console.log(values[this.name]);
            values[this.name] = $(this).val();
        });
        values = JSON.stringify(values);
        // console.log(values);
        // console.log(JSON.parse(values));
        //App.LocationController.prototype._actions.closeEditForm();
          $.ajax({
              url: '/location',
              type: 'POST',
              data: JSON.parse(values),
              processData: true,
              //contentType: "application/json; charset=utf-8",
              //dataType: "json",
              success: function(data, textStatus, jqXHR) {
                  //data - response from server
                  console.log('SUCCESS!', data);
                  $('.edit-success').css('display", "block');
                  $('body').css('background', 'lime');
                    console.log('MOAR SUCCESS');

                  window.location.href = 'allLocations#/locations/';

              },
              error: function(jqXHR, textStatus, errorThrown) {
                console.error('Some dumb error occurred');
                console.error(errorThrown);
              }
          });
    },
    closeEditForm: function() {
      //$('#edit_form').hide();
        $('.loc-table').fadeIn();
        App.$isEditing = false;
        //router.transitionTo('locations');
        window.location.href = 'allLocations#/locations/';
    }
  }
});

Handlebars.registerHelper('editLocation', function(options) {
    return 'allLocations#/locations/' + this.slug;
  });


Handlebars.registerHelper('addRowClass', function() {
    return 'olay-' + this.slug;
  });




