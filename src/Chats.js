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

import {Text, View, NativeModule, TouchableOpacity, Image} from 'react-native';
import {NativeModules, NativeEventEmitter} from 'react-native';
import {launchCamera, launchImageLibrary} from 'react-native-image-picker';

export const {GenesysMessenger} = NativeModules;
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
      console.log(JSON.stringify(res));
      if (res) {
        if (res.type === 'inbound') {
          addInboundMessage(res.message, res.data ? res.data : null);
        } else {
          addOutboundMessage(res.message);
        }
      }
    });
    return () => {};
  }, []);

  const addInboundMessage = (text, image) => {
    if (image) {
      setMessages(previousMessages =>
        GiftedChat.append(previousMessages, [
          {
            _id: Date.now().toString(),

            createdAt: new Date(),
            user: {
              _id: 1,
            },
            image: image,
          },
        ]),
      );
    } else {
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

  const uploadImage = async () => {
    console.log('aaaaa');
    try {
      const result = await launchImageLibrary({
        mediaType: 'photo',
        includeBase64: true,
      });
      console.log(result.assets[0].fileSize);
      GenesysMessenger.uploadAttachment(
        result.assets[0].base64,
        result.assets[0].fileName,
      );
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <View style={{flex: 1}}>
      <GiftedChat
        messages={messages}
        onSend={messages => onSend(messages)}
        user={{
          _id: 1,
        }}
        renderActions={renderActions}
      />
    </View>
  );
};

export default Chats;
