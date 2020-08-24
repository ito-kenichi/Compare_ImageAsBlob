import { StatusBar } from 'expo-status-bar';
import React, { Component } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import * as FileSystem from 'expo-file-system';
import * as SQLite from 'expo-sqlite';
// import * as Asset from 'expo-asset'
import { Asset } from "expo-asset";

var db;

export default class App extends Component {

  state = {
    text: 'nothing..',
    downloaded: false,
  };

  downloadDatabase = async () => {
  
    try {
      const sqliteDirectory = `${FileSystem.documentDirectory}`;
  
      const { exists, isDirectory } = await FileSystem.getInfoAsync(
        sqliteDirectory
      );

      var sqliDir = false;
      if (!exists) {
        sqliDir = await FileSystem.makeDirectoryAsync(`${sqliteDirectory}`);
      } else if (!isDirectory) {
        throw new Error('SQLite dir is not a directory');
      }

      const pathToDownloadTo = `${sqliteDirectory}assets/data.db`;
      const uriToDownload = Asset.fromModule(require('./assets/data.db')).uri;
    
      // console.log((await FileSystem.getInfoAsync(`${sqliteDirectory}assets/data.db`)).exists);
      await FileSystem.downloadAsync(uriToDownload, `${sqliteDirectory}assets/data.db`);
      db = SQLite.openDatabase('./assets/data.db');
      db.transaction(tx => {

        console.log("TEST");
        // tx.executeSql("select * from places");
        tx.executeSql(
          "select name, image from places",
          [],
          (_, resultSet) => {
            console.log("SUCCESS");
            this.setState({
              text: resultSet.map(x => x.name),
            })
            // SUCCESS
            setItems(resultSet);
              console.log("resultSet : " + resultSet);
            },
          (dbError) => {
            console.log("ERROR");
            console.log("fail : " + dbError);
          }
        );
      });
      console.log("db : " + db);
        
    } catch(error) {
        console.log(error);
    }
  }
  
  componentDidMount() {
    this.downloadDatabase();
  };
  
  render() {
    return (
      <View style={styles.container}>
        <Text>{this.state.text}</Text>
        <Text>Hello World</Text>
        <StatusBar style="auto" />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
