import React, { Component } from 'react';
import './App.css';
import {Container} from "semantic-ui-react"
import 'semantic-ui-css/semantic.min.css'
import Header from "./Header"
import Tokens from "./Tokens"
import Loteria from "./Loteria"
import Premios from "./Premios"
import {BrowserRouter,Route } from "react-router-dom"


class App extends Component {
  render() {
    return (
      <BrowserRouter>
        <Container>
        <Header />
          <main>
          
              <Route exact path="/" component= {Tokens}/>
              <Route exact path="/loteria" component= {Loteria}/>
              <Route exact path="/premio" component= {Premios}/>


            


          </main>


        </Container>
      
      
      </BrowserRouter>
    );
  }
}

export default App;
