import logo from "./logo.svg";

import { SafeAppsSDK } from "@gnosis.pm/safe-apps-sdk";
import Web3 from "web3";
import "./App.css";

function App() {
  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        await window.ethereum.enable();
        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.getAccounts();
        console.log("Connected to wallet:", accounts[0]);
      } catch (error) {
        console.error(error);
      }
    } else {
      console.error("Metamask not installed");
    }
  };

  const deploySafe = async () => {
    if (window.ethereum) {
      try {
        await window.ethereum.enable();
        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.getAccounts();

        // Set up Gnosis Safe SDK
        const sdk = new SafeAppsSDK();
        await sdk.setup({ ethereum: window.ethereum });

        // Create Safe with two signers (user and temporary address)
        const userAddress = accounts[0];
        const temporaryAddress = "0x1234567890123456789012345678901234567890";
        const safeAddress = await sdk.create({
          owners: [userAddress, temporaryAddress],
          threshold: 2,
          fallbackHandler: "0x0000000000000000000000000000000000000000",
          paymentToken: "0x0000000000000000000000000000000000000000",
        });

        console.log("Safe created with address:", safeAddress);
      } catch (error) {
        console.error(error);
      }
    } else {
      console.error("Metamask not installed");
    }
  };

  return (
    <div className="App">
      <h1>React Gnosis Safe Deployment</h1>
      <button onClick={connectWallet}>Log in with Metamask</button>
      <button onClick={deploySafe}>Deploy Safe</button>
    </div>
  );
}

export default App;
