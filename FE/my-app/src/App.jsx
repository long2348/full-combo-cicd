import React from 'react';
import './App.css';

function App() {
  return (
    <>
    <h4 className='h4-solar-title'>solar system v1.0.7</h4>
      <div className="solar-system">
        <div className="sun-container">
          <div className="sun"></div>
        </div>
        <div className="mercury orbit">
          <div className="planet"></div>
        </div>
        <div className="venus orbit">
          <div className="planet"></div>
        </div>
        <div className="earth orbit">
          <div className="planet"></div>
        </div>
        <div className="mars orbit">
          <div className="planet"></div>
        </div>
        <div className="jupiter orbit">
          <div className="planet"></div>
        </div>
        <div className="saturn orbit">
          <div className="planet"></div>
        </div>
        <div className="uranus orbit">
          <div className="planet"></div>
        </div>
        <div className="neptune orbit">
          <div className="planet"></div>
        </div>
      </div>
    </>
  );
}

export default App;