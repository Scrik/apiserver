app= angular.module 'engine.users', ['ngResource','ngRoute'], ($routeProvider) ->

    # Пользователи

    $routeProvider.when '/users',
        templateUrl: 'partials/users/', controller: 'UsersDashboardCtrl'

    $routeProvider.when '/users/user/list',
        templateUrl: 'partials/users/user/', controller: 'UsersUserListCtrl'

    $routeProvider.when '/users/user/create',
        templateUrl: 'partials/users/user/form/', controller: 'UsersUserFormCtrl'

    $routeProvider.when '/users/user/update/:userId',
        templateUrl: 'partials/users/user/form/', controller: 'UsersUserFormCtrl'





###

Ресурсы

###





###
Модель пользователя.
###
app.factory 'User', ($resource) ->
    $resource '/api/v1/users/:userId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                userId: '@id'

        delete:
            method: 'delete'
            params:
                userId: '@id'





###

Контроллеры

###


###
Контроллер панели управления.
###
app.controller 'UsersDashboardCtrl', ($scope, $q) ->
    $scope.state= 'loaded'


###
Контроллер списка серверов.
###
app.controller 'UsersUserListCtrl', ($scope, User) ->
    load= ->
        $scope.servers= User.query ->
            $scope.state= 'loaded'

    do load

    $scope.reload= ->
        do load


###
Контроллер формы сервера.
###
app.controller 'UsersUserFormCtrl', ($scope, $route, $location, User) ->
    if $route.current.params.serverId
        console.log $route.current.params.serverId
        $scope.server= User.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'

    else
        $scope.server= new User
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (UserForm) ->
        $scope.server.$create ->
            $location.path '/users/user/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        UserForm[input].$setValidity error.error, false

    $scope.update= (UserForm) ->
        $scope.server.$update ->
            $location.path '/users/user/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        UserForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.server.$delete ->
            $location.path '/users/user/list'
