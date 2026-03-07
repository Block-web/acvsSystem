ragma solidity ^0.8.0;

contract CertHashRegistry {
    // 事件：供 SDK 监听
    event Issued(string indexed certNo, string fileHash, uint256 collegeId, uint256 issueTime);
    event Revoked(string indexed certNo, uint256 revokeTime);

    struct Record {
        string  fileHash;   // PDF 指纹
        uint256 collegeId;  // 发证方
        uint256 issueTime;  // 发证时间
        uint8   status;     // 1 正常  0 撤销
    }

    mapping(string => Record) private _records; // key = certNo

    // 发证
    function issue(string memory certNo,
                   string memory fileHash,
                   uint256 collegeId) external {
        require(bytes(certNo).length == 16, "certNo length error");
        require(bytes(_records[certNo].fileHash).length == 0, "certNo exists");

        _records[certNo] = Record({
            fileHash: fileHash,
            collegeId: collegeId,
            issueTime: block.timestamp,
            status: 1
        });
        emit Issued(certNo, fileHash, collegeId, block.timestamp);
    }

    // 查询
    function verify(string memory certNo,
                    string memory fileHash,
                    uint256 collegeId) external view returns (bool) {
        Record memory r = _records[certNo];
        return keccak256(bytes(r.fileHash)) == keccak256(bytes(fileHash))
            && r.collegeId == collegeId
            && r.status == 1;
    }

    // 吊销（院校调用）
    function revoke(string memory certNo) external {
        Record storage r = _records[certNo];
        require(r.status == 1, "already revoked");
        r.status = 0;
        emit Revoked(certNo, block.timestamp);
    }
} 
