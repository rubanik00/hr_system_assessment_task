// SPDX-License-Identifier: GNU Lesser General Public License v3.0

pragma solidity 0.8.27;

import "./HiringProcessTypes.sol";

library HiringProcessErrorLib {
    error NOT_MANAGER(address caller);
    error NOT_HR_OR_MANAGER(address caller);
    error NOT_TECHNICAL_INTERVIEWER(address caller);
    error NOT_DESIGN_INTERVIEWER(address caller);
    error NOT_CODING_INTERVIEWER(address caller);
    error NOT_HR_INTERVIEWER(address caller);
    error STEP_ALREADY_COMPLETED(HiringProcessTypes.InterviewType interviewType);
}
