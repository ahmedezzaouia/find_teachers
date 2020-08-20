"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onConversationCreated = functions.firestore.document("Conversations/{conversationID}").onCreate((snapshot, context) => {
    let data = snapshot.data();
    let conversationID = context.params.conversationID;
    if (data) {
        let members = data.members;
        for (let index = 0; index < members.length; index++) {
            let currentUserID = members[index];
            let remainingUserIDs = members.filter((u: string) => u !== currentUserID);
            remainingUserIDs.forEach((m: string) => {
                return admin.firestore().collection("users").doc(m).get().then((_doc) => {
                    let userData = _doc.data();
                    if (userData) {
                        return admin.firestore().collection("users").doc(currentUserID).collection("Conversations").doc(m).create({
                            "conversationID": conversationID,
                            "image": userData['image'],
                            "name": userData['name'],
                            "unSeenCount": 0,
                            'lastMessage': '',

                        });
                    }
                    return null;
                }).catch(() => { return null; });
            });
        }
    }
    return null;
});

exports.sendNotificationMessage = functions.firestore.document("Conversations/{conversationID}").onUpdate((change, context) => {
    let newValue = change.after.data();
    let data = newValue.messages;
    let members = newValue.members;
    let senderID = data[data.length - 1].senderID;
    let remainingUserUId = members.filter((u: string) => u !== senderID);
    let body = '';
    if (data[data.length - 1].type == 'image') {
        body = 'Attachement an Image';
    }
    else {
        body = data[data.length - 1].content;
    }
    remainingUserUId.forEach((m: string) => {
        return admin.messaging().sendToTopic(m, {
            notification: {
                title: data[data.length - 1].senderName,
                body: body,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            }
        });
    });
});