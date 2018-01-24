(function() {
  "use strict";

  angular
    .module("spa-demo.subjects")
    .component("sdBusinessEditor", {
      templateUrl: businessEditorTemplateUrl,
      controller: BusinessEditorController,
      bindings: {
        authz: "<"
      },
      require: {
        businessesAuthz: "^sdBusinessesAuthz"
      }
    })

    .component("sdBusinessSelector", {
      templateUrl: businessSelectorTemplateUrl,
      controller: BusinessSelectorController,
      bindings: {
        authz: "<"
      },
    });

  businessSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function businessSelectorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.business_selector_html;
  }
  businessEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
  function businessEditorTemplateUrl(APP_CONFIG) {
    return APP_CONFIG.business_editor_html;
  }

  BusinessSelectorController.$inject = ["$scope",
                                     "$stateParams",
                                     "spa-demo.authz.Authz",
                                     "spa-demo.subjects.Business"];
  function BusinessSelectorController($scope, $stateParams, Authz, Business) {
    var vm=this;

    vm.$onInit = function() {
      console.log("BusinessSelectorController",$scope);
      $scope.$watch(function(){ return Authz.getAuthorizedUserId(); },
                    function(){
                      if (!$stateParams.id) {
                        vm.items = Business.query();
                      }
                    });
    }
    return;
    //////////////
  }


  BusinessEditorController.$inject = ["$scope","$q",
                                   "$state", "$stateParams",
                                   "spa-demo.authz.Authz",
                                   "spa-demo.subjects.Business",
                                   ];
  function BusinessEditorController($scope, $q, $state, $stateParams, Authz, Business) {
    var vm=this;
    vm.create = create;
    vm.clear  = clear;
    vm.update  = update;
    vm.remove  = remove;

    vm.$onInit = function() {
      console.log("BusinessEditorController", $scope);
      $scope.$watch(function(){ return Authz.getAuthorizedUserId(); },
                    function(){
                      if ($stateParams.id) {
                        reload($stateParams.id);
                      } else {
                        newResource();
                      }
                    });
    }
    return;
    //////////////
    function newResource() {
      console.log("newResource()");
      vm.item = new Business();
      vm.businessesAuthz.newItem(vm.item);
      return vm.item;
    }

    function reload(businessId) {
      var itemId = businessId ? businessId : vm.item.id;
      vm.item = Business.get({id:itemId});
      vm.businessesAuthz.newItem(vm.item);
      $q.all([vm.item.$promise]).catch(handleError);
      console.log("re/loading business", itemId);
      // console.log("$q:", $q.all([vm.item.$promise]).catch(handleError));
    }

    function clear() {
      newResource();
      $state.go(".", {id:null});
    }

    function create() {
      vm.item.$save().then(
        function(){
           $state.go(".", {id: vm.item.id});
        },
        handleError);
    }

    function update() {
      vm.item.errors = null;
      var update=vm.item.$update();
    }

    function remove() {
      vm.item.errors = null;
      vm.item.$delete().then(
        function(){
          console.log("remove complete", vm.item);
          clear();
        },
        handleError);
    }


    function handleError(response) {
      console.log("error", response);
      if (response.data) {
        vm.item["errors"]=response.data.errors;
      }
      if (!vm.item.errors) {
        vm.item["errors"]={}
        vm.item["errors"]["full_messages"]=[response];
      }
      $scope.businessform.$setPristine();
    }
  }

})();
