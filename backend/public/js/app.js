var locations = t.Locations;
App = Ember.Application.create({
  $isEditing: false

});

App.Router.map(function() {
  this.resource('locations', function() {
    this.resource('location', { path: ':slug' });
        App.$isEditing = false;

  });
});

App.LocationsRoute = Ember.Route.extend({
  model: function() {
    //console.log(locations[0]);
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
    openEdit: function(info) {
      if (App.$isEditing === false) {
        App.$isEditing = true;
        $('.loc-table').hide().promise().done(function() {
          $('#edit_form').fadeIn();
        });
        window.location.href = 'allLocations#/locations/' + info.slug;
      }
    },

      openDelete: function(info){
        var overlay = jQuery('<div id="overlay"></div>');
        //overlay.appendTo(document.body)

        var messageBox = jQuery('<div class="delete-olay">Are you sure you want to delete this?</div>');
        //messageBox.appendTo(document.body);
        $('#deleteModal').modal();
        $('.modal-loc-title').append(info.slug)

        
      },

        ajaxDelete: function(params) {
          var unparsed = {"_id": params._id, "slug": params.slug, "action": "delete"};
      $.ajax({
              url : '/location',
              type: 'POST',
              data : unparsed,
              processData: true,
              //contentType: "application/json; charset=utf-8",
              //dataType: "json",
              success: function(data, textStatus, jqXHR)
              {
                  console.log('Successfully deleted!');
                  $('.delete-success').css('display", "block');
                  window.location.href = 'allLocations#/locations/';
              },
              error: function(jqXHR, textStatus, errorThrown)
              {
                console.error('Some dumb error occurred');
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
        App.LocationController.prototype._actions.closeEditForm();
          $.ajax({
              url: '/location',
              type: 'POST',
              data: JSON.parse(values),
              processData: true,
              //contentType: "application/json; charset=utf-8",
              //dataType: "json",
              success: function(data, textStatus, jqXHR) {
                  //data - response from server
                  console.log('SUCCESS!');
                  $('.edit-success').css('display", "block');
                  window.location.href = 'allLocations#/locations/';
              },
              error: function(jqXHR, textStatus, errorThrown) {
                console.error('Some dumb error occurred');
                console.error(errorThrown);
              }
          });
    },
    closeEditForm: function() {
      $('#edit_form').hide();
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




// var showdown = new Showdown.converter();


// Ember.Handlebars.helper('format-markdown', function(input) {
//   return new Handlebars.SafeString(showdown.makeHtml(input));
// });

// Ember.Handlebars.helper('format-date', function(date) {
//   return moment(date).fromNow();
// });




