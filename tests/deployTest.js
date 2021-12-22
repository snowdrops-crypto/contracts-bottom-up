const { expect } = require('chai')
const { deployDiamond } = require('../scripts/deploy')

const getBalance = async (account) => {
  console.log(`Address: ${account.address}, balance: ${ethers.utils.formatEther(await account.getBalance())}`)
}

const generateDimensions = (num) => {
  const dims = []
  for (let i = 0; i < num; i++) {
    const surface = (Math.floor(Math.random() * 4)).toPrecision(2).toString()
    dims.push({
      surface: ethers.utils.parseUnits(surface, 0),
      positionX: ethers.utils.parseUnits('1.0', 0),
      positionY: ethers.utils.parseUnits('1.0', 0),
      positionZ: ethers.utils.parseUnits('1.0', 0),
      scaleX: ethers.utils.parseUnits('1.0', 0),
      scaleY: ethers.utils.parseUnits('1.0', 0),
      scaleZ: ethers.utils.parseUnits('1.0', 0),
      rotationX: ethers.utils.parseUnits('1.0', 0),
      rotationY: ethers.utils.parseUnits('1.0', 0),
      rotationZ: ethers.utils.parseUnits('1.0', 0),
    })
  }
  return dims
}

describe('Deploying Contracts', async () => {
  let deployVars
  const accounts = []

  before(async () => {
    deployVars = await deployDiamond('deployTest')
    const signers = await ethers.getSigners()
    for (let i = 0; i < 10; i++) {
      accounts.push(signers[i])
    }
    owner = accounts[0]
  })

  describe('SnowdropFacet', async () => {
    it('calls paySomething', async () => {
      console.log(ethers.utils.parseEther('1.0'))
      expect(
        await deployVars.snowdropFacet.paySomething({value: ethers.utils.parseEther('1.0')})
        // 1 ether = 10^18wei
      ).to.emit(deployVars.snowdropFacet, 'AmountPaid').withArgs(owner.address, ethers.utils.parseEther('1.0'));
    })
  
    it('gets snowdrops name and symbol', async () => {
      expect(await deployVars.snowdropFacet.name()).to.equal('Snowdrops')
      expect(await deployVars.snowdropFacet.symbol()).to.equal('SNOWDROPS')
    })
  
    // it('mints snowdrop and emits parameters', async () => {
    //   // deployVars.snowdropFacet.on("MintedSnowdrop", (from, to, value, event) => {
    //   //   console.log(from, to, value, event)
    //   // })
    //   // expect(await deployVars.snowdropFacet.mint()).to.emit(deployVars.snowdrops)
    //   // 1,000,000,000,000,000,000
    //   console.log(ethers.utils.parseEther('0.01'))
    //   await deployVars.snowdropFacet.mint(owner.address, {value: ethers.utils.parseEther('0.01')})
    //   await deployVars.snowdropFacet.connect(accounts[1]).mint(accounts[1].address, {value: ethers.utils.parseEther('0.01')})
    //   console.log(deployVars.snowdropFacet.address)
    //   // console.log(ethers.utils.formatEther(await accounts[0].getBalance()))
    //   await getBalance(accounts[0])
    //   console.log(await deployVars.snowdropFacet.getSnowdrop(0))
    //   console.log(await deployVars.snowdropFacet.getSnowdrop(1))
    //   // console.log(await deployVars.snowdropFacet.getSnowdrop(2))
    //   // const res = await tx.wait()
    //   // console.log(res.events[0])
    // })

    it('mints and transfers from one account to another', async () => {

    })

    it('updates card customization', async () => {
      // const dim = {
      //   surface: ethers.utils.parseUnits('0.0', 3),
      //   positionX: ethers.utils.parseUnits('1000.0', 3),
      //   positionY: ethers.utils.parseUnits('2000.0', 3),
      //   positionZ: ethers.utils.parseUnits('2000.0', 3),
      //   scaleX: ethers.utils.parseUnits('1000.0', 3),
      //   scaleY: ethers.utils.parseUnits('1000.0', 3),
      //   scaleZ: ethers.utils.parseUnits('1000.0', 3),
      //   rotation: ethers.utils.parseUnits('15000.0', 3)
      // }
      // const dimJson = JSON.stringify(dim)
      const dims = generateDimensions(4)

      await deployVars.snowdropFacet.updateCustomization(['10', '3', '5'], ['1', '2', '1'], dims)
    })
  })

  describe('ItemFacet', async () => {
    it('calls test function in itemFacet', async () => {
      expect(await deployVars.itemFacet.testFunc()).to.equal(10)
    })
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

    it('calls drawRandomNumberItem', async () => {
      await deployVars.vrfFacet.drawRandomNumberItem(10)
    })

    it('calls drawRandomNumberSnowdrop', async() => {
      expect(await deployVars.vrfFacet.drawRandomNumberSnowdrop('1'))
        .to.emit(deployVars.vrfFacet, 'VrfRandomNumber')
    })
  })
})