// SPDX-License-Identifier: GNU Lesser General Public License v3.0
pragma solidity 0.8.27;

import "@openzeppelin/contracts/access/AccessControl.sol";

import {HiringProcessErrorLib} from "./utils/HiringProcessErrorLib.sol";
import {HiringProcessTypes} from "./utils/HiringProcessTypes.sol";

contract HiringProcess is AccessControl {
    mapping(address => HiringProcessTypes.Candidate) private candidates; // Mapping of candidate status

    modifier onlyManager() {
        if (!hasRole(HiringProcessTypes.MANAGER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_MANAGER(msg.sender);
        }
        _;
    }

    modifier onlyHRorManager() {
        if (!hasRole(HiringProcessTypes.HR_ROLE, msg.sender) && !hasRole(HiringProcessTypes.MANAGER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_HR_OR_MANAGER(msg.sender);
        }
        _;
    }

    modifier onlyHR() {
        if (!hasRole(HiringProcessTypes.HR_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_HR_INTERVIEWER(msg.sender);
        }
        _;
    }

    modifier onlyTechnicalInterviewer() {
        if (!hasRole(HiringProcessTypes.TECHNICAL_INTERVIEWER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_TECHNICAL_INTERVIEWER(msg.sender);
        }
        _;
    }

    modifier onlyDesignInterviewer() {
        if (!hasRole(HiringProcessTypes.DESIGN_INTERVIEWER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_DESIGN_INTERVIEWER(msg.sender);
        }
        _;
    }

    modifier onlyCodingInterviewer() {
        if (!hasRole(HiringProcessTypes.CODING_INTERVIEWER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_CODING_INTERVIEWER(msg.sender);
        }
        _;
    }

    event InterviewUpdated(address candidate, HiringProcessTypes.InterviewType interviewType, bool passed);
    event CandidateVerified(address candidate);

    constructor(address _hr, address _techInterviewer, address _designInterviewer, address _codingInterviewer) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(HiringProcessTypes.MANAGER_ROLE, msg.sender);
        _grantRole(HiringProcessTypes.HR_ROLE, _hr);
        _grantRole(HiringProcessTypes.TECHNICAL_INTERVIEWER_ROLE, _techInterviewer);
        _grantRole(HiringProcessTypes.DESIGN_INTERVIEWER_ROLE, _designInterviewer);
        _grantRole(HiringProcessTypes.CODING_INTERVIEWER_ROLE, _codingInterviewer);
    }

    // Functions to update individual step status, only accessible to assigned persons
    function updateTechnicalInterview(address candidateAddress, bool passed) public onlyTechnicalInterviewer {
        if (candidates[candidateAddress].technicalInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.TECHNICAL);
        }

        if (passed) {
            candidates[candidateAddress].technicalInterviewPassed = HiringProcessTypes.Status.PASSED;
        } else {
            candidates[candidateAddress].technicalInterviewPassed = HiringProcessTypes.Status.FAILED;
        }
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.TECHNICAL, passed);
    }

    function updateDesignInterview(address candidateAddress, bool passed) public onlyDesignInterviewer {
        if (candidates[candidateAddress].designInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.DESIGN);
        }
        if (passed) {
            candidates[candidateAddress].designInterviewPassed = HiringProcessTypes.Status.PASSED;
        } else {
            candidates[candidateAddress].designInterviewPassed = HiringProcessTypes.Status.FAILED;
        }
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.DESIGN, passed);
    }

    function updateCodingInterview(address candidateAddress, bool passed) public onlyCodingInterviewer {
        if (candidates[candidateAddress].codingInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.CODING);
        }
        if (passed) {
            candidates[candidateAddress].codingInterviewPassed = HiringProcessTypes.Status.PASSED;
        } else {
            candidates[candidateAddress].codingInterviewPassed = HiringProcessTypes.Status.FAILED;
        }
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.CODING, passed);
    }

    function updateHrInterview(address candidateAddress, bool passed) public onlyHR {
        if (candidates[candidateAddress].hrInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.HR);
        }
        if (passed) {
            candidates[candidateAddress].hrInterviewPassed = HiringProcessTypes.Status.PASSED;
        } else {
            candidates[candidateAddress].hrInterviewPassed = HiringProcessTypes.Status.FAILED;
        }
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.HR, passed);
    }

    // Internal function to verify candidate if all steps are passed
    function _checkAndVerifyCandidate(address candidateAddress) internal {
        HiringProcessTypes.Candidate storage candidate = candidates[candidateAddress];

        if (
            candidate.technicalInterviewPassed == HiringProcessTypes.Status.PASSED
                && candidate.designInterviewPassed == HiringProcessTypes.Status.PASSED
                && candidate.codingInterviewPassed == HiringProcessTypes.Status.PASSED
                && candidate.hrInterviewPassed == HiringProcessTypes.Status.PASSED
        ) {
            candidate.verified = HiringProcessTypes.Status.PASSED;
            emit CandidateVerified(candidateAddress);
        }
    }

    // View candidate's status (Only HR and manager can access this)
    function getCandidateStatus(address candidateAddress)
        public
        view
        onlyHRorManager
        returns (
            HiringProcessTypes.Status technical,
            HiringProcessTypes.Status design,
            HiringProcessTypes.Status coding,
            HiringProcessTypes.Status hr,
            HiringProcessTypes.Status verified
        )
    {
        HiringProcessTypes.Candidate memory candidate = candidates[candidateAddress];
        return (
            candidate.technicalInterviewPassed,
            candidate.designInterviewPassed,
            candidate.codingInterviewPassed,
            candidate.hrInterviewPassed,
            candidate.verified
        );
    }
}
