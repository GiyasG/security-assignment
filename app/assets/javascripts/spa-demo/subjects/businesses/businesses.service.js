(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.Business", BusinessFactory);

  BusinessFactory.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
  function BusinessFactory($resource, APP_CONFIG) {
    var service = $resource(APP_CONFIG.server_url + "/api/businesses/:id",
      { id: '@id' },
      {
        update: {method: "PUT"},
        save:   {method: "POST", transformRequest: checkEmptyPayload }
      });
    return service;
  }

  //rails wants at least one parameter of the document filled in
  //all of our fields are optional
  //ngResource is not passing a null field by default, we have to force it
  function checkEmptyPayload(data) {
    if (!data['caption']) {
      data['caption']=null;
    }
    return angular.toJson(data);
  }
})();
