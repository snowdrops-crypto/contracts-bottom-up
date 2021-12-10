const { expect } = require('chai')
const { deployDiamond } = require('../scripts/deploy')

const getBalance = async (account) => {
  console.log(`Address: ${account.address}, balance: ${ethers.utils.formatEther(await account.getBalance())}`)
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

  it('prints the deploy vars', async () => {
    expect(await deployVars.snowdropFacet.setTestVar(10))
      .to.emit(deployVars.snowdropFacet, 'TestVarModified')
      .withArgs(owner.address, 10)

    expect(await deployVars.snowdropFacet.getTestVar())
      .to.equal(10)
  })

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

  it('mints snowdrop and emits parameters', async () => {
    // deployVars.snowdropFacet.on("MintedSnowdrop", (from, to, value, event) => {
    //   console.log(from, to, value, event)
    // })
    // expect(await deployVars.snowdropFacet.mint()).to.emit(deployVars.snowdrops)
    await deployVars.snowdropFacet.mint(owner.address)
    await deployVars.snowdropFacet.connect(accounts[1]).mint(accounts[1].address)
    console.log(deployVars.snowdropFacet.address)
    // console.log(ethers.utils.formatEther(await accounts[0].getBalance()))
    await getBalance(accounts[0])
    console.log(await deployVars.snowdropFacet.getSnowdrop(0))
    // const res = await tx.wait()
    // console.log(res.events[0])

  })

  it('calls test function in itemsFacet', async () => {
    expect(await deployVars.itemFacet.testFunc()).to.equal(10)
  })
})