import React, {useState, useEffect, useCallback} from 'react';
import {GiftedChat} from 'react-native-gifted-chat';
import initialMessages from './messages';
import {
  renderInputToolbar,
  renderActions,
  renderComposer,
  renderSend,
} from './InputToolbar';
import {
  renderAvatar,
  renderBubble,
  renderSystemMessage,
  renderMessage,
  renderMessageText,
  renderCustomView,
} from './MessageContainer';

import {Text, View, NativeModule} from 'react-native';
import {NativeModules, NativeEventEmitter} from 'react-native';

const {GenesysMessenger} = NativeModules;
const MessageEvents = new NativeEventEmitter(NativeModules.GenesysMessenger);

const Chats = () => {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    setMessages();
  }, []);

  const onSend = useCallback((messages = []) => {
    console.log(messages);
    // setMessages(previousMessages =>
    //   GiftedChat.append(previousMessages, messages),
    // );
    GenesysMessenger.sendMessage(messages[0].text);
  }, []);

  useEffect(() => {
    GenesysMessenger.setupGenesis();
    MessageEvents.addListener('onMessage', res => {
      if (res && res.message) {
        if (res.type === 'inbound') {
          addInboundMessage(res.message);
        } else {
          addOutboundMessage(res.message);
        }
      }
    });
    return () => {};
  }, []);

  const addInboundMessage = text => {
    if (text) {
      setMessages(previousMessages =>
        GiftedChat.append(previousMessages, [
          {
            _id: Date.now().toString(),
            text: text,
            createdAt: new Date(),
            user: {
              _id: 1,
            },
          },
        ]),
      );
    }
  };

  const addOutboundMessage = text => {
    setMessages(previousMessages =>
      GiftedChat.append(previousMessages, [
        {
          _id: Date.now().toString(),

          text: text,
          createdAt: new Date(),
          user: {
            _id: 2,
          },
        },
      ]),
    );
    // setMessages(previousMessages =>
    //   GiftedChat.append(previousMessages, messages),
    // );
  };

  return (
    <View style={{flex: 1}}>
      <GiftedChat
        messages={messages}
        onSend={messages => onSend(messages)}
        user={{
          _id: 1,
        }}
      />
    </View>
  );
};

export default Chats;
