import { useEffect } from 'react'
import { ethers } from 'ethers'
import vrfFacet from './artifacts/contracts/Snowdrops/facets/VRFFacet.sol/VRFFacet.json'
import './App.css';

const getBalance = async (addr, provider) => {
  let balance = await provider.getBalance(addr)
  balance = ethers.utils.formatEther(balance)
  console.log(balance)
}

const App = () => {
  const diamondAddr = '0xe9F36311067eb5E9A8d93fD6Cc0229a7C261Fd95'
  const usdc = {
    address: "0x68ec573C119826db2eaEA1Efbfc2970cDaC869c4",
    abi: [
      "function gimmeSome() external",
      "function balanceOf(address _owner) public view returns (uint256 balance)",
      "function transfer(address _to, uint256 _value) public returns (bool success)",
    ]
  }
  useEffect(() => {
    (async () => {
      const provider = new ethers.providers.Web3Provider(window.ethereum, "any")
      await provider.send("eth_requestAccounts", [])
      const signer = provider.getSigner()
      const addr = await signer.getAddress()
      console.log(addr)
      await getBalance(addr, provider)
      // let mySignature = await signer.signMessage("Some custom message");
      // console.log(mySignature)


      // const usdcContract = new ethers.Contract(usdc.address, usdc.abi, signer)
      const vrfContract = new ethers.Contract(diamondAddr, vrfFacet.abi, signer)
      console.log(vrfContract)
      const vrfAddr = await vrfContract.address
      console.log(vrfAddr)
      // const tnx = await vrfContract.expandRandom('123456789', '5')
      let tnx = await vrfContract.link()
      console.log(tnx)
      tnx = await vrfContract.linkBalance()
      console.log(ethers.utils.formatEther(tnx))
      // const tnxdone = await tnx.wait()
      // console.log(tnxdone)
    })()
  }, [])
  return (
    <div className="App">
      <header className="App-header">
      </header>
    </div>
  )
}

export default App;
