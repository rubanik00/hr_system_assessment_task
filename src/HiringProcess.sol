// SPDX-License-Identifier: GNU Lesser General Public License v3.0
pragma solidity 0.8.27;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {HiringProcessErrorLib} from "./utils/HiringProcessErrorLib.sol";
import {HiringProcessTypes} from "./utils/HiringProcessTypes.sol";

contract HiringProcess is AccessControl {
    mapping(address => HiringProcessTypes.Candidate) private candidates; // Mapping of candidate status

    /// @dev Restricts function execution to only the manager
    modifier onlyManager() {
        if (!hasRole(HiringProcessTypes.MANAGER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_MANAGER(msg.sender);
        }
        _;
    }

    /// @dev Restricts function execution to only HR or manager
    modifier onlyHRorManager() {
        if (!hasRole(HiringProcessTypes.HR_ROLE, msg.sender) && !hasRole(HiringProcessTypes.MANAGER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_HR_OR_MANAGER(msg.sender);
        }
        _;
    }

    /// @dev Restricts function execution to only HR personnel
    modifier onlyHR() {
        if (!hasRole(HiringProcessTypes.HR_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_HR_INTERVIEWER(msg.sender);
        }
        _;
    }

    /// @dev Restricts function execution to only technical interviewers
    modifier onlyTechnicalInterviewer() {
        if (!hasRole(HiringProcessTypes.TECHNICAL_INTERVIEWER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_TECHNICAL_INTERVIEWER(msg.sender);
        }
        _;
    }

    /// @dev Restricts function execution to only design interviewers
    modifier onlyDesignInterviewer() {
        if (!hasRole(HiringProcessTypes.DESIGN_INTERVIEWER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_DESIGN_INTERVIEWER(msg.sender);
        }
        _;
    }

    /// @dev Restricts function execution to only coding interviewers
    modifier onlyCodingInterviewer() {
        if (!hasRole(HiringProcessTypes.CODING_INTERVIEWER_ROLE, msg.sender)) {
            revert HiringProcessErrorLib.NOT_CODING_INTERVIEWER(msg.sender);
        }
        _;
    }

    /// @notice Emitted when an interview step is updated
    /// @param candidate The address of the candidate whose status is updated
    /// @param interviewType The type of interview being updated (technical, design, coding, or HR)
    /// @param passed Indicates whether the candidate passed the interview
    event InterviewUpdated(address candidate, HiringProcessTypes.InterviewType interviewType, bool passed);

    /// @notice Emitted when a candidate successfully passes all interview steps and is verified
    /// @param candidate The address of the verified candidate
    event CandidateVerified(address candidate);

    /// @dev Contract constructor to set up initial roles for manager, HR, and interviewers
    /// @param _hr The address of the HR personnel
    /// @param _techInterviewer The address of the technical interviewer
    /// @param _designInterviewer The address of the design interviewer
    /// @param _codingInterviewer The address of the coding interviewer
    constructor(address _hr, address _techInterviewer, address _designInterviewer, address _codingInterviewer) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(HiringProcessTypes.MANAGER_ROLE, msg.sender);
        _grantRole(HiringProcessTypes.HR_ROLE, _hr);
        _grantRole(HiringProcessTypes.TECHNICAL_INTERVIEWER_ROLE, _techInterviewer);
        _grantRole(HiringProcessTypes.DESIGN_INTERVIEWER_ROLE, _designInterviewer);
        _grantRole(HiringProcessTypes.CODING_INTERVIEWER_ROLE, _codingInterviewer);
    }

    /// @dev Updates the technical interview status for a candidate
    /// @param candidateAddress The address of the candidate
    /// @param passed Boolean value indicating whether the candidate passed the technical interview
    function updateTechnicalInterview(address candidateAddress, bool passed) public onlyTechnicalInterviewer {
        if (candidates[candidateAddress].technicalInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.TECHNICAL);
        }

        candidates[candidateAddress].technicalInterviewPassed =
            passed ? HiringProcessTypes.Status.PASSED : HiringProcessTypes.Status.FAILED;
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.TECHNICAL, passed);
    }

    /// @dev Updates the design interview status for a candidate
    /// @param candidateAddress The address of the candidate
    /// @param passed Boolean value indicating whether the candidate passed the design interview
    function updateDesignInterview(address candidateAddress, bool passed) public onlyDesignInterviewer {
        if (candidates[candidateAddress].designInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.DESIGN);
        }

        candidates[candidateAddress].designInterviewPassed =
            passed ? HiringProcessTypes.Status.PASSED : HiringProcessTypes.Status.FAILED;
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.DESIGN, passed);
    }

    /// @dev Updates the coding interview status for a candidate
    /// @param candidateAddress The address of the candidate
    /// @param passed Boolean value indicating whether the candidate passed the coding interview
    function updateCodingInterview(address candidateAddress, bool passed) public onlyCodingInterviewer {
        if (candidates[candidateAddress].codingInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.CODING);
        }

        candidates[candidateAddress].codingInterviewPassed =
            passed ? HiringProcessTypes.Status.PASSED : HiringProcessTypes.Status.FAILED;
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.CODING, passed);
    }

    /// @dev Updates the HR interview status for a candidate
    /// @param candidateAddress The address of the candidate
    /// @param passed Boolean value indicating whether the candidate passed the HR interview
    function updateHrInterview(address candidateAddress, bool passed) public onlyHR {
        if (candidates[candidateAddress].hrInterviewPassed != HiringProcessTypes.Status.PENDING) {
            revert HiringProcessErrorLib.STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType.HR);
        }

        candidates[candidateAddress].hrInterviewPassed =
            passed ? HiringProcessTypes.Status.PASSED : HiringProcessTypes.Status.FAILED;
        _checkAndVerifyCandidate(candidateAddress);
        emit InterviewUpdated(candidateAddress, HiringProcessTypes.InterviewType.HR, passed);
    }

    /// @dev Internal function that verifies the candidate if all interview steps are passed
    /// @param candidateAddress The address of the candidate to verify
    /// @notice This function will set the candidate's status to verified if they pass all interview stages
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

    /// @dev Retrieves the status of the candidate across all interview stages
    /// @param candidateAddress The address of the candidate
    /// @return technical The status of the technical interview
    /// @return design The status of the design interview
    /// @return coding The status of the coding interview
    /// @return hr The status of the HR interview
    /// @return verified The final verification status of the candidate
    /// @notice Only HR or the manager can access this function
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
