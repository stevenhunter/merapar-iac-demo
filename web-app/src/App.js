import './App.css';
import axios from 'axios';
import { useState, useEffect } from 'react';

function App() {
  let apiUrl =  window.location.href + "api";
  const client = axios.create({
    baseURL: apiUrl
  });

  const [dynamicContent, setDynamicContent] = useState([]);

  useEffect(() => {
    client.get().then((response) => {
      setDynamicContent(response.data);
    });
  }, []);
  
  return (
    <div className="App">
      <h1>The saved string is {dynamicContent}</h1>
    </div>
  );
}

export default App;
