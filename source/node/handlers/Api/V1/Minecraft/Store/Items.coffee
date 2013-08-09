express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c предметами.
###
app= module.exports= do express



###
Отдает список предметов.
###
app.get '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM store_item'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает предмет.
###
app.get '/:itemId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM store_item WHERE id = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item= do resp.shift if not err
                    return done err, conn, item

        (conn, item, done) ->
            conn.query "
                SELECT e.`id`, e.`identity`, e.`title`, e.`levelmax`, ie.`level`
                FROM store_item_enchantments as ie
                JOIN store_enchantment as e
                    ON ie.enchantmentId = e.id
                WHERE ie.itemId = ?
                ORDER BY ie.order
                "
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item.enchantments= resp
                    return done err, conn, item

        (conn, item, done) ->
            conn.query "
                SELECT
                    Server.`id`,
                    Server.`name`,
                    Server.`title`
                FROM store_item_servers as StoreItem
                JOIN server as Server
                    ON StoreItem.serverId = Server.id
                WHERE StoreItem.itemId = ?
                "
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item.servers= resp
                    return done err, conn, item

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not item
            return res.json 200, item



###
Добавляет предмет.
###
app.post '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            data=
                title: req.body.title
                imageUrl: req.body.imageUrl
                material: req.body.material
            conn.query "
                INSERT INTO store_item SET ?
                "
            ,   [data]
            ,   (err, resp) ->
                    id= resp.insertId if not err
                    return done err, conn, id

        (conn, id, done) ->
            bulk= []
            for enchantment, order in req.body.enchantments
                bulk.push [id, enchantment.id, enchantment.level, order]
            conn.query "
                INSERT INTO store_item_enchantments
                    (`itemId`, `enchantmentId`, `level`, `order`)
                VALUES ?
                "
            ,   [bulk]
            ,   (err, resp) ->
                    return done err, conn, id

        (conn, id, done) ->
            bulk= []
            for server in req.body.servers
                bulk.push [id, server.id]
            conn.query "
                INSERT INTO store_item_servers
                    (`itemId`, `serverId`)
                VALUES ?
                "
            ,   [bulk]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 201, req.body



###
Обновляет предмет.
###
app.put '/:itemId', access, (req, res, next) ->

    itemId= req.params.itemId
    delete req.body.id

    item= req.body

    enchantments= item.enchantments or []
    delete item.enchantments

    servers= item.servers or []
    delete item.servers

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE store_item SET ? WHERE id = ?'
            ,   [item, itemId]
            ,   (err, resp) ->
                    console.log arguments
                    return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM store_item_enchantments WHERE itemId = ?'
            ,   [itemId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not enchantments.length

                    bulk= []
                    for enchantment, order in enchantments
                        bulk.push [itemId, enchantment.id, enchantment.level, order]
                    conn.query "
                        INSERT INTO store_item_enchantments (`itemId`, `enchantmentId`, `level`, `order`) VALUES ?
                        "
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM store_item_servers WHERE itemId = ?'
            ,   [itemId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not servers.length

                    bulk= []
                    for server in servers
                        bulk.push [itemId, server.id]
                    conn.query 'INSERT INTO store_item_servers (`itemId`, `serverId`) VALUES ?'
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn


        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, req.body



###
Удаляет предмет.
###
app.delete '/:itemId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM store_item WHERE id = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item= {} if not err
                    return done err, conn, item

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 200, item
