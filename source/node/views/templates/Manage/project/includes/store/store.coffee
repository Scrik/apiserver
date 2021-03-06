app= angular.module 'project.store', ['ngResource','ngRoute'], ($routeProvider) ->

    # Магазин

    $routeProvider.when '/store',
        templateUrl: 'partials/store/', controller: 'StoreDashboardCtrl'

    # Магазин. История покупок

    $routeProvider.when '/store/orders/list',
        templateUrl: 'partials/store/orders/', controller: 'StoreOrderListCtrl'

    # Магазин. Предметы

    $routeProvider.when '/store/items/list',
        templateUrl: 'partials/store/items/', controller: 'StoreItemListCtrl'

    $routeProvider.when '/store/items/item/create',
        templateUrl: 'partials/store/items/item/form/', controller: 'StoreItemFormCtrl'

    $routeProvider.when '/store/items/item/update/:itemId',
        templateUrl: 'partials/store/items/item/form/', controller: 'StoreItemFormCtrl'

    # Bukkit. Материалы

    $routeProvider.when '/store/materials/list',
        templateUrl: 'partials/store/materials/', controller: 'StoreMaterialListCtrl'

    $routeProvider.when '/store/materials/material/create',
        templateUrl: 'partials/store/materials/material/form/', controller: 'StoreMaterialFormCtrl'

    $routeProvider.when '/store/materials/material/update/:materialId',
        templateUrl: 'partials/store/materials/material/form/', controller: 'StoreMaterialFormCtrl'

    # Bukkit. Чары

    $routeProvider.when '/store/enchantments/list',
        templateUrl: 'partials/store/enchantments/', controller: 'StoreEnchantmentCtrl'

    $routeProvider.when '/store/enchantments/enchantment/create',
        templateUrl: 'partials/store/enchantments/enchantment/form/', controller: 'StoreEnchantmentFormCtrl'

    $routeProvider.when '/store/enchantments/enchantment/update/:enchantmentId',
        templateUrl: 'partials/store/enchantments/enchantment/form/', controller: 'StoreEnchantmentFormCtrl'





###

Ресурсы

###


###
Модель материала.
###
app.factory 'Material', ($resource) ->
    $resource '/api/v1/bukkit/materials/:materialId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                materialId: '@id'

        delete:
            method: 'delete'
            params:
                materialId: '@id'



###
Модель чар.
###
app.factory 'Enchantment', ($resource) ->
    $resource '/api/v1/bukkit/enchantments/:enchantmentId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                enchantmentId: '@id'

        delete:
            method: 'delete'
            params:
                enchantmentId: '@id'



###
Модель предмета.
###
app.factory 'Item', ($resource) ->
    $resource '/api/v1/servers/item/:itemId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                itemId: '@id'

        delete:
            method: 'delete'
            params:
                itemId: '@id'



app.factory 'ServerList', ($resource) ->
    $resource '/api/v1/servers/server'



app.factory 'TagList', ($resource) ->
    $resource '/api/v1/tags/'





###

Контроллеры

###


###
Контроллер панели управления.
###
app.controller 'StoreDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'


###
Контроллер списка покупок.
###
app.controller 'StoreOrderListCtrl', ($scope, $location, Order) ->
    load= ->
        $scope.orders= Order.query (orders) ->
            $scope.state= 'loaded'
            console.log 'Заказы загружены', orders

    do load





###
Контроллер материалов баккита
###
app.controller 'StoreMaterialListCtrl', ($scope, $location, Material) ->
    load= ->
        $scope.materials= Material.query ->
            $scope.state= 'loaded'

    do load

    $scope.reload= ->
        do load



###
Контроллер формы материала.
###
app.controller 'StoreMaterialFormCtrl', ($scope, $route, $q, $location, Material) ->
    if $route.current.params.materialId
        $scope.material= Material.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.material= new Material
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (MaterialForm) ->
        $scope.material.$create ->
            $location.path '/store/materials/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        MaterialForm[input].$setValidity error.error, false

    $scope.update= (MaterialForm) ->
        $scope.material.$update ->
            $location.path '/store/materials/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        MaterialForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.material.$delete ->
            $location.path '/store/materials/list'





###
Контроллер чар баккита
###
app.controller 'StoreEnchantmentCtrl', ($scope, $location, Enchantment) ->
    load= ->
        $scope.enchantments= Enchantment.query ->
            $scope.state= 'loaded'

    do load

    $scope.reload= ->
        do load



###
Контроллер формы чара.
###
app.controller 'StoreEnchantmentFormCtrl', ($scope, $route, $q, $location, Enchantment) ->
    if $route.current.params.enchantmentId
        $scope.enchantment= Enchantment.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.enchantment= new Enchantment
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (EnchantmentForm) ->
        $scope.enchantment.$create ->
            $location.path '/store/enchantments/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        EnchantmentForm[input].$setValidity error.error, false

    $scope.update= (EnchantmentForm) ->
        $scope.enchantment.$update ->
            $location.path '/store/enchantments/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        EnchantmentForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.enchantment.$delete ->
            $location.path '/store/enchantments/list'





###
Контроллер списка предметов.
###
app.controller 'StoreItemListCtrl', ($scope, $location, Item) ->
    load= ->
        $scope.items= Item.query ->
            $scope.state= 'loaded'
            console.log 'Предметы загружены'

    do load

    $scope.showDetails= (item) ->
        $scope.dialog.item= item
        $scope.dialog.templateUrl= 'item/dialog/'
        $scope.showDialog true

    $scope.hideDetails= ->
        $scope.dialog.item= null
        do $scope.hideDialog

    $scope.reload= ->
        do load



###
Контроллер формы предмета.
###
app.controller 'StoreItemFormCtrl', ($scope, $route, $q, $location, Item, Material, Enchantment, ServerList, TagList) ->
    if $route.current.params.itemId
        $scope.item= Item.get $route.current.params, ->
            $scope.materials= Material.query ->
                $scope.enchantments= Enchantment.query ->
                    $scope.servers= ServerList.query ->
                        $scope.tags= TagList.query ->
                            $scope.state= 'loaded'
                            $scope.action= 'update'
    else
        $scope.item= new Item
        $scope.materials= Material.query ->
            $scope.enchantments= Enchantment.query ->
                $scope.servers= ServerList.query ->
                    $scope.tags= TagList.query ->
                        $scope.state= 'loaded'
                        $scope.action= 'create'


    $scope.filterServer= (server) ->
        isThere= true
        if $scope.item.servers
            $scope.item.servers.map (srv) ->
                if srv.id == server.id
                    isThere= false

        return isThere


    # ищем теги подходящие выбранным серверам
    $scope.filterTag= (tag) ->
        isThere= false
        if $scope.item.servers
            $scope.item.servers.map (server) ->
                if tag.serverId == server.id
                    isThere= true

        if $scope.item.tags
            $scope.item.tags.map (t) ->
                if t.id == tag.id
                    isThere= false

        return isThere



    $scope.changeMaterial= (material) ->
        $scope.item.titleRu= JSON.parse(material).titleRu
        $scope.item.titleEn= JSON.parse(material).titleEn


    $scope.addEnchantment= (enchantment) ->
        newEnchantment= JSON.parse angular.copy enchantment
        newEnchantment.level= 1
        $scope.item.enchantments= [] if not $scope.item.enchantments
        $scope.item.enchantments.push newEnchantment


    $scope.removeEnchantment= (enchantment) ->
        remPosition= null
        $scope.item.enchantments.map (ench, i) ->
            if ench.id == enchantment.id
                $scope.item.enchantments.splice i, 1


    $scope.addServer= (server) ->
        newServer= JSON.parse angular.copy server
        $scope.item.servers= [] if not $scope.item.servers
        $scope.item.servers.push newServer


    $scope.removeServer= (server) ->
        remPosition= null
        $scope.item.servers.map (srv, i) ->
            if srv.id == server.id
                $scope.item.servers.splice i, 1


    $scope.addTag= (tag) ->
        newTag= JSON.parse angular.copy tag
        $scope.item.tags= [] if not $scope.item.tags
        $scope.item.tags.push newTag


    $scope.removeTag= (tag) ->
        remPosition= null
        $scope.item.tags.map (t, i) ->
            if t.id == tag.id
                $scope.item.tags.splice i, 1





    # Действия

    $scope.create= (ItemForm) ->
        $scope.item.material= JSON.parse($scope.item.material).id
        $scope.item.$create ->
            $location.path '/store/items/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ItemForm[input].$setValidity error.error, false

    $scope.update= (ItemForm) ->
        $scope.item.$update ->
            $location.path '/store/items/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ItemForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.item.$delete ->
            $location.path '/store/items/list'
