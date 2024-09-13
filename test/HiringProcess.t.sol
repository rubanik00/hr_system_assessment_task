// SPDX-License-Identifier: GNU Lesser General Public License v3.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../src/HiringProcess.sol";
import "../src/utils/HiringProcessErrorLib.sol";
import "../src/utils/HiringProcessTypes.sol";

contract HiringProcessTest is Test {
    HiringProcess hiringProcessContract;

    address manager;

    address hr1;
    address hr2;

    address techInterviewer1;
    address techInterviewer2;

    address designInterviewer1;
    address designInterviewer2;

    address codingInterviewer1;
    address codingInterviewer2;

    address candidate1;
    address candidate2;

    address hacker;

    function setUp() public {
        manager = vm.addr(1);

        hr1 = vm.addr(2);
        hr2 = vm.addr(3);

        techInterviewer1 = vm.addr(4);
        techInterviewer2 = vm.addr(5);

        designInterviewer1 = vm.addr(6);
        designInterviewer2 = vm.addr(7);

        codingInterviewer1 = vm.addr(8);
        codingInterviewer2 = vm.addr(9);

        candidate1 = vm.addr(10);
        candidate2 = vm.addr(11);

        hacker = vm.addr(12);

        vm.startPrank(manager);
        hiringProcessContract = new HiringProcess(hr1, techInterviewer1, designInterviewer1, codingInterviewer1);
        hiringProcessContract.grantRole(HiringProcessTypes.HR_ROLE, hr2);
        hiringProcessContract.grantRole(HiringProcessTypes.TECHNICAL_INTERVIEWER_ROLE, techInterviewer2);
        hiringProcessContract.grantRole(HiringProcessTypes.DESIGN_INTERVIEWER_ROLE, designInterviewer2);
        hiringProcessContract.grantRole(HiringProcessTypes.CODING_INTERVIEWER_ROLE, codingInterviewer2);
        vm.stopPrank();
    }

    // Test a successful technical interview update
    function testTechnicalInterviewPass() public {
        vm.prank(techInterviewer1);
        hiringProcessContract.updateTechnicalInterview(candidate1, true);

        vm.prank(manager);
        (HiringProcessTypes.Status tech, , , , ) = hiringProcessContract.getCandidateStatus(candidate1);
        assertEq(uint(tech), uint(HiringProcessTypes.Status.PASSED));
    }

    // Test error when non-technical interviewer tries to update technical interview
    function testFailTechnicalInterviewUnauthorized() public {
        vm.prank(hacker);
        hiringProcessContract.updateTechnicalInterview(candidate1, true);
    }

    // Test successful design interview update
    function testDesignInterviewPass() public {
        vm.prank(designInterviewer1);
        hiringProcessContract.updateDesignInterview(candidate1, true);

        vm.prank(manager);
        (, HiringProcessTypes.Status design, , , ) = hiringProcessContract.getCandidateStatus(candidate1);
        assertEq(uint(design), uint(HiringProcessTypes.Status.PASSED));
    }

    // Test error when unauthorized user updates design interview
    function testFailDesignInterviewUnauthorized() public {
        vm.prank(hacker);
        hiringProcessContract.updateDesignInterview(candidate1, true);
    }

    // Test successful coding interview update
    function testCodingInterviewPass() public {
        vm.prank(codingInterviewer1);
        hiringProcessContract.updateCodingInterview(candidate1, true);

        vm.prank(manager);
        (, , HiringProcessTypes.Status coding, , ) = hiringProcessContract.getCandidateStatus(candidate1);
        assertEq(uint(coding), uint(HiringProcessTypes.Status.PASSED));
    }

    // Test error when unauthorized user updates coding interview
    function testFailCodingInterviewUnauthorized() public {
        vm.prank(hacker);
        hiringProcessContract.updateCodingInterview(candidate1, true);
    }

    // Test successful HR interview update
    function testHrInterviewPass() public {
        vm.startPrank(hr1);
        hiringProcessContract.updateHrInterview(candidate1, true);

        (, , , HiringProcessTypes.Status hr, ) = hiringProcessContract.getCandidateStatus(candidate1);
        assertEq(uint(hr), uint(HiringProcessTypes.Status.PASSED));
        vm.stopPrank();
    }

    // Test error when unauthorized user updates HR interview
    function testFailHrInterviewUnauthorized() public {
        vm.prank(hacker);
        hiringProcessContract.updateHrInterview(candidate1, true);
    }

    // Test final verification when all steps are passed
    function testCandidateVerification() public {
        vm.prank(techInterviewer1);
        hiringProcessContract.updateTechnicalInterview(candidate1, true);

        vm.prank(designInterviewer1);
        hiringProcessContract.updateDesignInterview(candidate1, true);

        vm.prank(codingInterviewer1);
        hiringProcessContract.updateCodingInterview(candidate1, true);

        vm.startPrank(hr1);
        hiringProcessContract.updateHrInterview(candidate1, true);

        (, , , , HiringProcessTypes.Status verified) = hiringProcessContract.getCandidateStatus(candidate1);
        assertEq(uint(verified), uint(HiringProcessTypes.Status.PASSED));
        vm.stopPrank();
    }

    // Test that a candidate cannot be verified if not all interviews are passed
    function testCandidateNotVerifiedIfNotAllStepsPassed() public {
        vm.prank(techInterviewer1);
        hiringProcessContract.updateTechnicalInterview(candidate1, true);

        vm.prank(designInterviewer1);
        hiringProcessContract.updateDesignInterview(candidate1, true);

        // Coding interview is failed
        vm.prank(codingInterviewer1);
        hiringProcessContract.updateCodingInterview(candidate1, false);

        vm.startPrank(hr1);
        hiringProcessContract.updateHrInterview(candidate1, true);

        (, , , , HiringProcessTypes.Status verified) = hiringProcessContract.getCandidateStatus(candidate1);
        assertEq(uint(verified), uint(HiringProcessTypes.Status.PENDING));
        vm.stopPrank();
    }

    // Test that a step cannot be updated twice
    function testFailStepCannotBeUpdatedTechIntTwice() public {
        vm.startPrank(techInterviewer1);
        hiringProcessContract.updateTechnicalInterview(candidate1, true);

        vm.expectRevert(HiringProcessErrorLib.STEP_ALREADY_COMPLETED.selector);
        hiringProcessContract.updateTechnicalInterview(candidate1, false);

        vm.stopPrank();
    }

    function testFailStepCannotBeUpdatedDesignIntTwice() public {
        vm.startPrank(designInterviewer1);
        hiringProcessContract.updateDesignInterview(candidate1, true);

        vm.expectRevert(HiringProcessErrorLib.STEP_ALREADY_COMPLETED.selector);
        hiringProcessContract.updateDesignInterview(candidate1, false);

        vm.stopPrank();
    }

    function testFailStepCannotBeUpdatedCodingIntTwice() public {
        vm.startPrank(codingInterviewer1);
        hiringProcessContract.updateCodingInterview(candidate1, true);

        vm.expectRevert(HiringProcessErrorLib.STEP_ALREADY_COMPLETED.selector);
        hiringProcessContract.updateCodingInterview(candidate1, false);

        vm.stopPrank();
    }

    function testFailStepCannotBeUpdatedHrIntTwice() public {
        vm.startPrank(hr1);
        hiringProcessContract.updateHrInterview(candidate1, true);

        vm.expectRevert(HiringProcessErrorLib.STEP_ALREADY_COMPLETED.selector);
        hiringProcessContract.updateHrInterview(candidate1, false);

        vm.stopPrank();
    }
}