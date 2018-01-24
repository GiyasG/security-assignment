(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .directive("sdBusinessesAuthz", BusinessesAuthzDirective);

  BusinessesAuthzDirective.$inject = [];

  function BusinessesAuthzDirective() {
    var directive = {
        bindToController: true,
        controller: BusinessesAuthzController,
        controllerAs: "vm",
        restrict: "A",
        link: link
    };
    return directive;

    function link(scope, element, attrs) {
      console.log("BusinessesAuthzDirective", scope);
    }
  }

  BusinessesAuthzController.$inject = ["$scope",
                                   "spa-demo.subjects.BusinessesAuthz"];
  function BusinessesAuthzController($scope, BusinessesAuthz) {
    var vm = this;
    vm.authz={};
    vm.authz.canUpdateItem = canUpdateItem;
    vm.newItem=newItem;

    activate();
    return;
    //////////
    function activate() {
      vm.newItem(null);
    }

    function newItem(item) {
      BusinessesAuthz.getAuthorizedUser().then(
        function(user){ authzUserItem(item, user); },
        function(user){ authzUserItem(item, user); });
    }

    function authzUserItem(item, user) {
      console.log("new Item/Authz", item, user);

      vm.authz.authenticated = BusinessesAuthz.isAuthenticated();
      vm.authz.canQuery      = BusinessesAuthz.canQuery();
      vm.authz.canCreate = BusinessesAuthz.canCreate();
      if (item && item.$promise) {
        vm.authz.canUpdate     = false;
        vm.authz.canDelete     = false;
        vm.authz.canGetDetails = false;
        item.$promise.then(function(){ checkAccess(item); });
      } else {
        checkAccess(item)
      }
    }

    function checkAccess(item) {
      vm.authz.canUpdate     = BusinessesAuthz.canUpdate(item);
      vm.authz.canDelete     = BusinessesAuthz.canDelete(item);
      vm.authz.canGetDetails = BusinessesAuthz.canGetDetails(item);
      console.log("checkAccess:", item);
      console.log("vm.authz:", vm.authz);
    }

    function canUpdateItem(item) {
      return BusinessesAuthz.canUpdate(item);
    }
  }
})();
