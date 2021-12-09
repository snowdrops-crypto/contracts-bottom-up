const { expect } = require('chai')
const { deployDiamond } = require('../scripts/deploy')

describe('Deploying Contracts', async () => {
  let deployVars
  let owner

  before(async () => {
    deployVars = await deployDiamond('deployTest')
    owner = (await ethers.getSigners())[0]
  })

  it('prints the deploy vars', async () => {
    expect(await deployVars.snowdropsFacet.setTestVar(10))
      .to.emit(deployVars.snowdropsFacet, 'TestVarModified')
      .withArgs(owner.address, 10)

    expect(await deployVars.snowdropsFacet.getTestVar())
      .to.equal(10)
  })

  it('calls paySomething', async () => {
    console.log(ethers.utils.parseEther('1.0'))
    expect(
      await deployVars.snowdropsFacet.paySomething({value: ethers.utils.parseEther('1.0')})
      // 1 ether = 10^18wei
    ).to.emit(deployVars.snowdropsFacet, 'AmountPaid').withArgs(owner.address, ethers.utils.parseEther('1.0'));
  })

  it('gets a snowdrop', async () => {
    console.log(await deployVars.snowdropsFacet.getSnowdrop(1))
  })

  it('gets snowdrops name and symbol', async () => {
    expect(await deployVars.snowdropsFacet.name()).to.equal('Snowdrops')
    expect(await deployVars.snowdropsFacet.symbol()).to.equal('SNOWDROPS')
  })

  it('mints snowdrop and emits parameters', async () => {
    // deployVars.snowdropsFacet.on("MintedSnowdrop", (from, to, value, event) => {
    //   console.log(from, to, value, event)
    // })
    const tx = await deployVars.snowdropsFacet.mint()
    const res = await tx.wait()
    console.log(res.events[0].getTransactionReceipt())

  })

  it('calls test function in itemsFacet', async () => {
    expect(await deployVars.itemsFacet.testFunc()).to.equal(10)
  })
})