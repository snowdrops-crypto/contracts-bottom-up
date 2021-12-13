const { expect } = require('chai')
const { deployDiamond } = require('../scripts/deployOnlyVrf')

const getBalance = async (account) => {
  console.log(`Address: ${account.address}, balance: ${ethers.utils.formatEther(await account.getBalance())}`)
}

describe('Deploying Contracts', async () => {
  let deployVars
  const accounts = []

  before(async () => {
    deployVars = await deployDiamond('deployTestVrf_1')
    const signers = await ethers.getSigners()
    for (let i = 0; i < 10; i++) {
      accounts.push(signers[i])
    }
    owner = accounts[0]
  })

  describe('VRFFacet', async () => {
    // it('calls vrf facet test function', async () => {
    //   await deployVars.vrfFacet.testFuncVRF();
    // })

    it('gets the link balance', async () => {
      console.log(await deployVars.vrfFacet.linkBalance())
    })

    it('gets the vrfCoordinator', async () => {
      console.log(await deployVars.vrfFacet.vrfCoordinator())
    })

    it('gets the link address', async () => {
      console.log(await deployVars.vrfFacet.link())
    })

    it('gets the keyHash', async () => {
      console.log(await deployVars.vrfFacet.keyHash())
    })

    it('draws randomenss', async () => {
      await deployVars.vrfFacet.testMint('1');
    })
  })
})