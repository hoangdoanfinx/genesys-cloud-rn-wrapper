/* eslint-disable react/destructuring-assignment */
/* eslint-disable react/jsx-props-no-spreading */
import React from 'react';
import {Image} from 'react-native';
import {InputToolbar, Actions, Composer, Send} from 'react-native-gifted-chat';
import {launchCamera, launchImageLibrary} from 'react-native-image-picker';
import {NativeModules, NativeEventEmitter, Text} from 'react-native';
import {GenesysMessenger} from './Chats';

export const renderInputToolbar = props => (
  <InputToolbar
    {...props}
    containerStyle={{
      backgroundColor: '#222B45',
    }}
    primaryStyle={{alignItems: 'center'}}
  />
);

export const renderActions = props => {
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
    <Actions
      {...props}
      containerStyle={{
        width: 44,
        height: 44,
        alignItems: 'center',
        justifyContent: 'center',
        marginLeft: 4,
        marginRight: 4,
        marginBottom: 0,
      }}
      icon={() => <Text>Attach</Text>}
      options={{
        'Choose From Library': () => {
          uploadImage();
        },
        Cancel: () => {
          console.log('Cancel');
        },
      }}
      optionTintColor="#222B45"
    />
  );
};

export const renderComposer = props => (
  <Composer
    {...props}
    textInputStyle={{
      color: '#222B45',
      backgroundColor: '#EDF1F7',
      borderWidth: 1,
      borderRadius: 5,
      borderColor: '#E4E9F2',
      paddingTop: 8.5,
      paddingHorizontal: 12,
      marginLeft: 0,
    }}
  />
);

export const renderSend = props => (
  <Send
    {...props}
    disabled={!props.text}
    containerStyle={{
      width: 44,
      height: 44,
      alignItems: 'center',
      justifyContent: 'center',
      marginHorizontal: 4,
    }}>
    <Image
      style={{width: 32, height: 32}}
      source={{
        uri: 'https://placeimg.com/32/32/any',
      }}
    />
  </Send>
);
