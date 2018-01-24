(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .factory("spa-demo.subjects.BusinessesAuthz", BusinessesAuthzFactory);

  BusinessesAuthzFactory.$inject = ["spa-demo.authz.Authz",
                                    "spa-demo.authz.BasePolicy"];
  function BusinessesAuthzFactory(Authz, BasePolicy) {
    function BusinessesAuthz() {
      BasePolicy.call(this, "Business");
    }

      //start with base class prototype definitions
    BusinessesAuthz.prototype = Object.create(BasePolicy.prototype);
    BusinessesAuthz.constructor = BusinessesAuthz;

      //override and add additional methods
    BusinessesAuthz.prototype.canCreate=function() {
      //console.log("ItemsAuthz.canCreate");
      return Authz.isAuthenticated();
    };

    return new BusinessesAuthz();
  }
})();
