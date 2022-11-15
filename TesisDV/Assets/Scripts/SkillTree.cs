using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SkillTree : MonoBehaviour
{
    private Inventory _inventory;

    #region Trap Unlocks

    [Header("Microwave Trap")]
    [Header("Trap Unlocks")]
    [SerializeField] private int MicrowaveTrapWittCost;
    private bool _isMicrowaveTrapUnlocked;
    public bool isMicrowaveTrapUnlocked
    {
        get { return _isMicrowaveTrapUnlocked; }
    }
    [Header("Slow Trap")]
    [SerializeField] private int SlowTrapWittCost;
    private bool _isSlowTrapUnlocked;
    public bool isSlowTrapUnlocked
    {
        get { return _isSlowTrapUnlocked; }
    }
    [Header("Electric Trap")]
    [SerializeField] private int ElectricTrapWittCost;
    private bool _isElectricTrapUnlocked;
    public bool isElectricTrapUnlocked
    {
        get { return _isElectricTrapUnlocked; }
    }
    [Header("Darts Trap")]
    [SerializeField] private int DartsTrapWittCost;
    private bool _isDartsTrapUnlocked;
    public bool isDartsTrapUnlocked
    {
        get { return _isDartsTrapUnlocked; }
    }

    #endregion

    #region BaseballLauncher Upgrades

    [Header("Static Balls")]
    [Header("BaseballLauncher Upgrades")]
    [SerializeField] private int BL1WittCost;
    private bool _isBL1Activated;
    public bool isBL1Activated
    {
        get { return _isBL1Activated; }
    }
    [Header("Firerate Upgrade")]
    [SerializeField] private int BL2WittCost;
    private bool _isBL2Activated;
    public bool isBL2Activated
    {
        get { return _isBL2Activated; }
    }

    #endregion

    #region NailFiringMachine Upgrades

    [Header("Damage Upgrade")]
    [Header("NailFiringMachine Upgrades")]
    [SerializeField] private int NFM1WittCost;
    private bool _isNFM1Activated;
    public bool isNFM1Activated
    {
        get { return _isNFM1Activated; }
    }
    [Header("Toxic Damage")]
    [SerializeField] private int NFM2WittCost;
    private bool _isNFM2Activated;
    public bool isNFM2Activated
    {
        get { return _isNFM2Activated; }
    }

    #endregion

    #region ElectricTrap Upgrades

    [Header("Focus On Enemy")]
    [Header("ElectricTrap Upgrades")]
    [SerializeField] private int ET1WittCost;
    private bool _isET1Activated;
    public bool isET1Activated
    {
        get { return _isET1Activated; }
    }
    [Header("Area Upgrade")]
    [SerializeField] private int ET2WittCost;
    private bool _isET2Activated;
    public bool isET2Activated
    {
        get { return _isET2Activated; }
    }

    #endregion

    #region SlowTrap Upgrades

    [Header("Effect Upgrade")]
    [Header("SlowTrap Upgrades")]
    [SerializeField] private int ST1WittCost;
    private bool _isST1Activated;
    public bool isST1Activated
    {
        get { return _isST1Activated; }
    }
    [Header("Toxic Damage")]
    [SerializeField] private int ST2WittCost;
    private bool _isST2Activated;
    public bool isST2Activated
    {
        get { return _isST2Activated; }
    }

    #endregion

    #region MicrowaveTrap Upgrades

    [Header("More Resistance")]
    [Header("MicrowaveTrap Upgrades")]
    [SerializeField] private int MT1WittCost;
    private bool _isMT1Activated;
    public bool isMT1Activated
    {
        get { return _isMT1Activated; }
    }
    [Header("Return Damage")]
    [SerializeField] private int MT2WittCost;
    private bool _isMT2Activated;
    public bool isMT2Activated
    {
        get { return _isMT2Activated; }
    }
    [Header("Explode On Death")]
    [SerializeField] private int MT3WittCost;
    private bool _isMT3Activated;
    public bool isMT3Activated
    {
        get { return _isMT3Activated; }
    }

    #endregion
    
    public delegate void OnUpgradeDelegate();
    public event OnUpgradeDelegate OnUpgrade;

    void Start()
    {
        _inventory = GetComponentInChildren<Inventory>();
    }

    #region ButtonVoids

    public void UnlockMicrowaveTrap()
    {
        if(!_isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MicrowaveTrapWittCost))
        {
            _inventory.RemoveWitts(MicrowaveTrapWittCost);
            _isMicrowaveTrapUnlocked = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UnlockSlowTrap()
    {
        if(!_isSlowTrapUnlocked && _inventory.HasEnoughWitts(SlowTrapWittCost))
        {
            _inventory.RemoveWitts(SlowTrapWittCost);
            _isSlowTrapUnlocked = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UnlockElectricTrap()
    {
        if(!_isElectricTrapUnlocked && _inventory.HasEnoughWitts(ElectricTrapWittCost))
        {
            _inventory.RemoveWitts(ElectricTrapWittCost);
            _isElectricTrapUnlocked = true;
            OnUpgrade?.Invoke();
        } 
    }
    public void UnlockDartsTrap()
    {
        if(!_isDartsTrapUnlocked && _inventory.HasEnoughWitts(DartsTrapWittCost))
        {
            _inventory.RemoveWitts(DartsTrapWittCost);
            _isDartsTrapUnlocked = true;
            OnUpgrade?.Invoke();
        }
        
    }

    public void UpgradeBaseballLauncher1()
    {
        if(!_isBL1Activated && _inventory.HasEnoughWitts(BL1WittCost))
        {
            _inventory.RemoveWitts(BL1WittCost);
            _isBL1Activated = true;
            OnUpgrade?.Invoke();
        }
        
    }

    public void UpgradeBaseballLauncher2()
    {
        if(!_isBL2Activated && _inventory.HasEnoughWitts(BL2WittCost))
        {
            _inventory.RemoveWitts(BL2WittCost);
            _isBL2Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeNailFiringMachine1()
    {
        if(!_isNFM1Activated && _isDartsTrapUnlocked && _inventory.HasEnoughWitts(NFM1WittCost))
        {
            _inventory.RemoveWitts(NFM1WittCost);
            _isNFM1Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeNailFiringMachine2()
    {
        if(!_isNFM2Activated && _isDartsTrapUnlocked && _inventory.HasEnoughWitts(NFM2WittCost))
        {
            _inventory.RemoveWitts(NFM2WittCost);
            _isNFM2Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeElectricTrap1()
    {
        if(!_isET1Activated && _isElectricTrapUnlocked && _inventory.HasEnoughWitts(ET1WittCost))
        {
            _inventory.RemoveWitts(ET1WittCost);
            _isET1Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeElectricTrap2()
    {
        if(!_isET2Activated && _isElectricTrapUnlocked && _inventory.HasEnoughWitts(ET2WittCost))
        {
            _inventory.RemoveWitts(ET2WittCost);
            _isET2Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeSlowTrap1()
    {
        if(!_isST1Activated && _isSlowTrapUnlocked && _inventory.HasEnoughWitts(ST1WittCost))
        {
            _inventory.RemoveWitts(ST1WittCost);
            _isST1Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeSlowTrap2()
    {
        if(!_isST2Activated && _isSlowTrapUnlocked && _inventory.HasEnoughWitts(ST2WittCost))
        {
            _inventory.RemoveWitts(ST2WittCost);
            _isST2Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeMicrowaveTrap1()
    {
        if(!_isMT1Activated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT1WittCost))
        {
            _inventory.RemoveWitts(MT1WittCost);
            _isMT1Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeMicrowaveTrap2()
    {
        if(!_isMT2Activated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT2WittCost))
        {
            _inventory.RemoveWitts(MT2WittCost);
            _isMT2Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeMicrowaveTrap3()
    {
        if(!_isMT3Activated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT3WittCost))
        {
            _inventory.RemoveWitts(MT3WittCost);
            _isMT3Activated = true;
            OnUpgrade?.Invoke();
        }
    }

    #endregion
}
