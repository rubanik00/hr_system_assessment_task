// SPDX-License-Identifier: GNU Lesser General Public License v3.0

pragma solidity 0.8.27;

library HiringProcessTypes {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant HR_ROLE = keccak256("HR_ROLE");
    bytes32 public constant TECHNICAL_INTERVIEWER_ROLE = keccak256("TECHNICAL_INTERVIEWER_ROLE");
    bytes32 public constant DESIGN_INTERVIEWER_ROLE = keccak256("DESIGN_INTERVIEWER_ROLE");
    bytes32 public constant CODING_INTERVIEWER_ROLE = keccak256("CODING_INTERVIEWER_ROLE");

    enum Status {
        PENDING, // Default status
        PASSED, // Interview passed
        FAILED // Interview failed

    }

    enum InterviewType {
        TECHNICAL,
        DESIGN,
        CODING,
        HR
    }

    struct Candidate {
        Status technicalInterviewPassed;
        Status designInterviewPassed;
        Status codingInterviewPassed;
        Status hrInterviewPassed;
        Status verified;
    }
}
