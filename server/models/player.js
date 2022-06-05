const mongoose = require("mongoose");

const playerSchemal = new mongoose.Schema({
    nickname:{
        type:String,
        trim:true,
    },
    socketID:{
        type:String,
    },
    isPartyLeader:{
        type:Boolean,
        default:false,
    },
    points:{
        type:Number,
        default:0
    }
});

const playermodel = mongoose.model("Player",playerSchemal);
module.exports = {playermodel,playerSchemal};