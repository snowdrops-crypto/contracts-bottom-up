const { expect } = require('chai')
const { deployDiamond } = require('../scripts/deploy')

describe('Deploying Contracts', async () => {
  let deployVars
  before(async () => {
    deployVars = await deployDiamond('deployTest')
  })
  it('prints the deploy vars', async () => {
    console.log(deployVars.account)
  })
})