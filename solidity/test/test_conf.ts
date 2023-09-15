import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';

describe('deployed', () => {

    it('test set questions', async () => {
        const [owner, cooperator] = await ethers.getSigners();
        const address = await owner.getAddress();
        const cooperatorAddr = await cooperator.getAddress();
        console.log('cooperatorAddr: ', cooperatorAddr);

        const Conf = await ethers.getContractFactory('ZKMEConfUpgradeable');
        const conf = await upgrades.deployProxy(
            Conf,
            [
                address
            ],
            { initializer: 'initialize' }
        );

        await conf.deployed();

        const questions = ["6168752826443568356578851982882135008485", "7721528705884867793143365084876737116315"];

        await expect(conf.setQuestions(cooperatorAddr, questions))
            .to.emit(conf, "SetQuestion")
            .withArgs(cooperatorAddr);

        const res = await conf.getQuestions(cooperatorAddr);

        expect(res).to.be.deep.equal(questions);
    });
});
