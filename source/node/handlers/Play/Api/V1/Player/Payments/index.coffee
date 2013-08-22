express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c платежами аутентифицированного игрока.
###
app= module.exports= do express



app.get '/', access, (req, res, next) ->

    data= []

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    PlayerPayment.id,
                    PlayerPayment.amount,
                    PlayerPayment.status,
                    PlayerPayment.createdAt,
                    PlayerPayment.closedAt
                FROM
                    ?? as PlayerPayment
                WHERE
                    PlayerPayment.playerId = ?
                ORDER BY
                    PlayerPayment.createdAt DESC
                "
            ,   [req.user.id]
            ,   (err, rows) ->
                    data= rows if not err
                    return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, data



app.post '/', access, (req, res, next) ->

    data=
        playerId: req.user
        amount: req.body.amount

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                INSERT INTO ??
                SET ?
                "
            ,   ['player_payment', data]
            ,   (err, result) ->
                    data.id= result.insertId if not err
                    return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, data



app.get '/:paymentId', access, (req, res, next) ->

    playerId= req.user.id
    paymentId= req.params.paymentId

    data= null

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    PlayerPayment.id,
                    PlayerPayment.amount,
                    PlayerPayment.status,
                    PlayerPayment.createdAt,
                    PlayerPayment.closedAt
                FROM
                    ?? as PlayerPayment
                WHERE
                    PlayerPayment.playerId = ? AND
                    PlayerPayment.id = ?
                "
            ,   ['player_payment', playerId, paymentId]
            ,   (err, rows) ->
                    data= do rows.shift if not err
                    return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, data
