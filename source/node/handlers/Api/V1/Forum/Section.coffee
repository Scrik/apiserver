express= require 'express'
async= require 'async'

###
Методы API для работы c разделами форумов
###
app= module.exports= do express



###
Добавляет раздел.
###
app.post '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'INSERT INTO forum_section SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    section= req.body
                    section.id= resp.insertId

                    return done err, conn, section

        (conn, section, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, section

    ],  (err, conn, section) ->
            do conn.end if conn

            return next err if err
            return res.json 200, section



###
Отдает список инстансов.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum_section'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает инстанс.
###
app.get '/:sectionId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum_section WHERE id = ?'
            ,   [req.params.sectionId]
            ,   (err, resp) ->
                    section= do resp.shift if not err
                    return done err, conn, section

    ],  (err, conn, section) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not section
            return res.json 200, section



###
Изменяет инстанс
###
app.put '/:sectionId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE forum_section SET ? WHERE id = ?'
            ,   [req.body, req.params.sectionId]
            ,   (err, resp) ->
                    section= req.body
                    section.id= req.params.sectionId
                    return done err, conn, section

        (conn, section, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, section

    ],  (err, conn, section) ->
            do conn.end if conn

            return next err if err
            return res.json 200, section



###
Удаляет инстанс
###
app.delete '/:sectionId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM forum_section WHERE id = ?'
            ,   [req.params.sectionId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200

