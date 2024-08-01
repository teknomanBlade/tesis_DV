using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class SkillTree : MonoBehaviour
{
    private Inventory _inventory;
    private AudioSource _as;
    [Range(0, 1)]
    public float soundVolume;

    #region Upgrades UI Components
    public GameObject UnlockSTTrap;
    public GameObject UnlockMTTrap;
    public GameObject UnlockETTrap;
    public GameObject UnlockFPMTrap;
    public GameObject UpgradeBL1a;
    public GameObject UpgradeBL1b;
    public GameObject UpgradeBL2a;
    public GameObject UpgradeBL2b;
    public GameObject UpgradeST1a;
    public GameObject UpgradeST1b;
    public GameObject UpgradeST2a;
    public GameObject UpgradeST2b;
    public GameObject UpgradeMT1a;
    public GameObject UpgradeMT1b;
    public GameObject UpgradeMT2a;
    public GameObject UpgradeMT2b;
    public GameObject UpgradeET1a;
    public GameObject UpgradeET1b;
    public GameObject UpgradeET2a;
    public GameObject UpgradeET2b;
    public GameObject UpgradeFPM1a;
    public GameObject UpgradeFPM1b;
    public GameObject UpgradeFPM2a;
    public GameObject UpgradeFPM2b;
    #endregion

    #region Trap Unlocks

    [Header("Microwave Trap")]
    [Header("Trap Unlocks")]
    [SerializeField] private int MicrowaveTrapWittCost;
    public Text MTWitCostText;
    private bool _isMicrowaveTrapUnlocked;
    public bool isMicrowaveTrapUnlocked
    {
        get { return _isMicrowaveTrapUnlocked; }
    }
    [Header("Slow Trap")]
    [SerializeField] private int SlowTrapWittCost;
    public Text STWitCostText;
    private bool _isSlowTrapUnlocked;
    public bool isSlowTrapUnlocked
    {
        get { return _isSlowTrapUnlocked; }
    }
    [Header("Electric Trap")]
    [SerializeField] private int ElectricTrapWittCost;
    public Text ETWitCostText;
    private bool _isElectricTrapUnlocked;
    public bool isElectricTrapUnlocked
    {
        get { return _isElectricTrapUnlocked; }
    }
    [Header("Paintball Minigun Trap")]
    [SerializeField] private int PaintballMinigunTrapWittCost;
    public Text FPMTrapWitCostText;
    private bool _isPaintballMinigunTrapUnlocked;
    public bool isPaintballMinigunTrapUnlocked
    {
        get { return _isPaintballMinigunTrapUnlocked; }
    }

    #endregion

    #region BaseballLauncher Upgrades

    [Header("Damage Upgrade")]
    [Header("BaseballLauncher Upgrades")]
    [Space]
    [SerializeField] private int BL1aWittCost;
    public Text BLUpdate1aWitCostText;
    private bool _isBL1aActivated;
    public bool isBL1aActivated
    {
        get { return _isBL1aActivated; }
    }
    [Header("Static Balls")]
    [SerializeField] private int BL1bWittCost;
    public Text BLUpdate1bWitCostText;
    private bool _isBL1bActivated;
    public bool isBL1bActivated
    {
        get { return _isBL1bActivated; }
    }
    [Header("Double Loader Small")]
    [SerializeField] private int BL2aWittCost;
    public Text BLUpdate2aWitCostText;
    private bool _isBL2aActivated;
    public bool isBL2aActivated
    {
        get { return _isBL2aActivated; }
    }
    [Header("Double Loader Large")]
    [SerializeField] private int BL2bWittCost;
    public Text BLUpdate2bWitCostText;
    private bool _isBL2bActivated;
    public bool isBL2bActivated
    {
        get { return _isBL2bActivated; }
    }

    #endregion

    #region SlowTrap Upgrades

    [Header("Slow Increase +50 Upgrade")]
    [Header("SlowTrap Upgrades")]
    [SerializeField] private int ST1aWittCost;
    public Text STUpdate1aWitCostText;
    private bool _isST1aActivated;
    public bool isST1aActivated
    {
        get { return _isST1aActivated; }
    }
    [Header("Slow Increase +100 Upgrade")]
    [SerializeField] private int ST1bWittCost;
    public Text STUpdate1bWitCostText;
    private bool _isST1bActivated;
    public bool isST1bActivated
    {
        get { return _isST1bActivated; }
    }
    [Header("Toxic Damage")]
    [SerializeField] private int ST2aWittCost;
    public Text STUpdate2aWitCostText;
    private bool _isST2aActivated;
    public bool isST2aActivated
    {
        get { return _isST2aActivated; }
    }
    [Header("Toxic Damage Increase")]
    [SerializeField] private int ST2bWittCost;
    public Text STUpdate2bWitCostText;
    private bool _isST2bActivated;
    public bool isST2bActivated
    {
        get { return _isST2bActivated; }
    }

    #endregion

    #region MicrowaveTrap Upgrades

    [Header("+ 100 Resistance")]
    [Header("MicrowaveTrap Upgrades")]
    [SerializeField] private int MT1aWittCost;
    public Text MTUpdate1aWitCostText;
    private bool _isMT1aActivated;
    public bool isMT1aActivated
    {
        get { return _isMT1aActivated; }
    }
    [Header("+ 200 Resistance")]
    [SerializeField] private int MT1bWittCost;
    public Text MTUpdate1bWitCostText;
    private bool _isMT1bActivated;
    public bool isMT1bActivated
    {
        get { return _isMT1bActivated; }
    }
    [Header("Double Shieldings")]
    [SerializeField] private int MT2aWittCost;
    public Text MTUpdate2aWitCostText;
    private bool _isMT2aActivated;
    public bool isMT2aActivated
    {
        get { return _isMT2aActivated; }
    }
    [Header("Return Damage")]
    [SerializeField] private int MT2bWittCost;
    public Text MTUpdate2bWitCostText;
    private bool _isMT2bActivated;
    public bool isMT2bActivated
    {
        get { return _isMT2bActivated; }
    }


    #endregion

    #region ElectricTrap Upgrades

    [Header("Double Damage Upgrade")]
    [Header("ElectricTrap Upgrades")]
    [SerializeField] private int ET1aWittCost;
    public Text ETUpdate1aWitCostText;
    private bool _isET1aActivated;
    public bool isET1aActivated
    {
        get { return _isET1aActivated; }
    }
    [Header("DPS Increase Upgrade")]
    [SerializeField] private int ET1bWittCost;
    public Text ETUpdate1bWitCostText;
    private bool _isET1bActivated;
    public bool isET1bActivated
    {
        get { return _isET1bActivated; }
    }
    [Header("Double Range Upgrade")]
    [SerializeField] private int ET2aWittCost;
    public Text ETUpdate2aWitCostText;
    private bool _isET2aActivated;
    public bool isET2aActivated
    {
        get { return _isET2aActivated; }
    }
    [Header("Area of Effect Upgrade")]
    [SerializeField] private int ET2bWittCost;
    public Text ETUpdate2bWitCostText;
    private bool _isET2bActivated;
    public bool isET2bActivated
    {
        get { return _isET2bActivated; }
    }

    #endregion

    #region FERN Paintball Minigun Upgrades

    [Header("Double Damage Upgrade")]
    [Header("FERN Paintball Minigun Upgrades")]
    [SerializeField] private int FPM1aWittCost;
    public Text FPMUpdate1aWitCostText;
    private bool _isFPM1aActivated;
    public bool isFPM1aActivated
    {
        get { return _isFPM1aActivated; }
    }
    [Header("Pepper Pellets Upgrade")]
    [SerializeField] private int FPM1bWittCost;
    public Text FPMUpdate1bWitCostText;
    private bool _isFPM1bActivated;
    public bool isFPM1bActivated
    {
        get { return _isFPM1bActivated; }
    }
    [Header("+ 50 Shots")]
    [SerializeField] private int FPM2aWittCost;
    public Text FPMUpdate2aWitCostText;
    private bool _isFPM2aActivated;
    public bool isFPM2aActivated
    {
        get { return _isFPM2aActivated; }
    }
    [Header("+ 5 Hit Points")]
    [SerializeField] private int FPM2bWittCost;
    public Text FPMUpdate2bWitCostText;
    private bool _isFPM2bActivated;
    public bool isFPM2bActivated
    {
        get { return _isFPM2bActivated; }
    }

    #endregion

    public delegate void OnUpgradeDelegate();
    public event OnUpgradeDelegate OnUpgrade;

    void Awake()
    {
        STWitCostText.text = SlowTrapWittCost.ToString();
        MTWitCostText.text = MicrowaveTrapWittCost.ToString();
        FPMTrapWitCostText.text = PaintballMinigunTrapWittCost.ToString();
        ETWitCostText.text = ElectricTrapWittCost.ToString();

        BLUpdate1aWitCostText.text = BL1aWittCost.ToString();
        BLUpdate1bWitCostText.text = BL1bWittCost.ToString();
        BLUpdate2aWitCostText.text = BL2aWittCost.ToString();
        BLUpdate2bWitCostText.text = BL2bWittCost.ToString();
        STUpdate1aWitCostText.text = ST1aWittCost.ToString();
        STUpdate1bWitCostText.text = ST1bWittCost.ToString();
        STUpdate2aWitCostText.text = ST2aWittCost.ToString();
        STUpdate2bWitCostText.text = ST2bWittCost.ToString();
        MTUpdate1aWitCostText.text = MT1aWittCost.ToString();
        MTUpdate1bWitCostText.text = MT1bWittCost.ToString();
        MTUpdate2aWitCostText.text = MT2aWittCost.ToString();
        MTUpdate2bWitCostText.text = MT2bWittCost.ToString();
        ETUpdate1aWitCostText.text = ET1aWittCost.ToString();
        ETUpdate1bWitCostText.text = ET1bWittCost.ToString();
        ETUpdate2aWitCostText.text = ET2aWittCost.ToString();
        ETUpdate2bWitCostText.text = ET2bWittCost.ToString();
        FPMUpdate1aWitCostText.text = FPM1aWittCost.ToString();
        FPMUpdate1bWitCostText.text = FPM1bWittCost.ToString();
        FPMUpdate2aWitCostText.text = FPM2aWittCost.ToString();
        FPMUpdate2bWitCostText.text = FPM2bWittCost.ToString();
        HandleUIBL1bComponents(true, false, 0.2196078f);
        HandleUIBL2bComponents(true, false, 0.2196078f);
        HandleUIST1aComponents(true, false, 0.2196078f);
        HandleUIST1bComponents(true, false, 0.2196078f);
        HandleUIST2aComponents(true, false, 0.2196078f);
        HandleUIST2bComponents(true, false, 0.2196078f);
        HandleUIMT1aComponents(true, false, 0.2196078f);
        HandleUIMT1bComponents(true, false, 0.2196078f);
        HandleUIMT2aComponents(true, false, 0.2196078f);
        HandleUIMT2bComponents(true, false, 0.2196078f);
        HandleUIET1aComponents(true, false, 0.2196078f);
        HandleUIET1bComponents(true, false, 0.2196078f);
        HandleUIET2aComponents(true, false, 0.2196078f);
        HandleUIET2bComponents(true, false, 0.2196078f);
        HandleUIFPM1aComponents(true, false, 0.2196078f);
        HandleUIFPM1bComponents(true, false, 0.2196078f);
        HandleUIFPM2aComponents(true, false, 0.2196078f);
        HandleUIFPM2bComponents(true, false, 0.2196078f);

        _inventory = GetComponentInChildren<Inventory>();
        _as = GetComponent<AudioSource>();
    }

    #region Upgrades UI Methods
    public void HandleUISTUnlockComponents() 
    {
        UnlockSTTrap.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("SpriteTarSlowingTrap"))
            {
                 x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
            }

            if (x.name.Contains("BtnBuyTrapUnlock"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
                x.GetComponent<Button>().interactable = false;
            }
        });
    }
    public void HandleUIMTUnlockComponents()
    {
        UnlockMTTrap.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("SpriteMicrowaveForceFieldTrap"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
            }

            if (x.name.Contains("BtnBuyTrapUnlock"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
                x.GetComponent<Button>().interactable = false;
            }
        });
    }
    public void HandleUIETUnlockComponents()
    {
        UnlockETTrap.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("SpriteElectricTrap"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
            }

            if (x.name.Contains("BtnBuyTrapUnlock"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
                x.GetComponent<Button>().interactable = false;
            }
        });
    }
    public void HandleUIFPMUnlockComponents()
    {
        UnlockFPMTrap.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("SpriteFERNPaintballMinigun"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
            }

            if (x.name.Contains("BtnBuyTrapUnlock"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, 0.2196078f);
                x.GetComponent<Button>().interactable = false;
            }
        });
    }
    public void HandleUIBL1aComponents(bool enabled, bool interactable, float imageAlpha = 1f) 
    {
        UpgradeBL1a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1a"))
            {
                x.GetComponent<Image>().color = new Color(1f,1f,1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIBL1bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeBL1b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1b"))
            {
                //disabledValue = 0.2196078f, enabledValue = 1f
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIBL1aComponents() 
    {
        HandleUIBL1aComponents(false, true);
    }
    public void EnableUIBL1bComponents()
    {
        HandleUIBL1bComponents(false, true);
    }
    public void HandleUIBL2aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeBL2a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIBL2bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeBL2b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIBL2aComponents()
    {
        HandleUIBL2aComponents(false, true);
    }
    public void EnableUIBL2bComponents()
    {
        HandleUIBL2bComponents(false, true);
    }
    public void HandleUIST1aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeST1a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIST1bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeST1b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIST1aComponents()
    {
        HandleUIST1aComponents(false, true);
    }
    public void EnableUIST1bComponents()
    {
        HandleUIST1bComponents(false, true);
    }
    public void HandleUIST2aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeST2a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIST2bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeST2b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }

    public void EnableUIST2aComponents()
    {
        HandleUIST2aComponents(false, true);
    }
    public void EnableUIST2bComponents()
    {
        HandleUIST2bComponents(false, true);
    }
    public void HandleUIMT1aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeMT1a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIMT1bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeMT1b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIMT1aComponents()
    {
        HandleUIMT1aComponents(false, true);
    }
    public void EnableUIMT1bComponents()
    {
        HandleUIMT1bComponents(false, true);
    }
    public void HandleUIMT2aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeMT2a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIMT2bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeMT2b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIMT2aComponents()
    {
        HandleUIMT2aComponents(false, true);
    }
    public void EnableUIMT2bComponents()
    {
        HandleUIMT2bComponents(false, true);
    }

    public void HandleUIET1aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeET1a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIET1bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeET1b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIET1aComponents()
    {
        HandleUIET1aComponents(false, true);
    }
    public void EnableUIET1bComponents() 
    {
        HandleUIET1bComponents(false,true);
    }
    public void HandleUIET2aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeET2a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIET2bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeET2b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIET2aComponents()
    {
        HandleUIET2aComponents(false, true);
    }
    public void EnableUIET2bComponents()
    {
        HandleUIET2bComponents(false, true);
    }
    public void HandleUIFPM1aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeFPM1a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIFPM1bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeFPM1b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption1b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIFPM1aComponents()
    {
        HandleUIFPM1aComponents(false, true);
    }
    public void EnableUIFPM1bComponents()
    {
        HandleUIFPM1bComponents(false, true);
    }
    public void HandleUIFPM2aComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeFPM2a.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2a"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void HandleUIFPM2bComponents(bool enabled, bool interactable, float imageAlpha = 1f)
    {
        UpgradeFPM2b.GetComponentsInChildren<RectTransform>(true).ToList().ForEach(x =>
        {
            if (x.name.Contains("ImgBoughtOption"))
            {
                x.gameObject.SetActive(enabled);
            }

            if (x.name.Contains("BtnBuyOption2b"))
            {
                x.GetComponent<Image>().color = new Color(1f, 1f, 1f, imageAlpha);
                x.GetComponent<Button>().interactable = interactable;
            }
        });
    }
    public void EnableUIFPM2aComponents()
    {
        HandleUIFPM2aComponents(false, true);
    }
    public void EnableUIFPM2bComponents()
    {
        HandleUIFPM2bComponents(false, true);
    }
    #endregion

    #region ButtonVoids

    public void UnlockMicrowaveTrap()
    {
        if(!_isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MicrowaveTrapWittCost))
        {
            HandleUIMTUnlockComponents();
            EnableUIMT1aComponents();
            EnableUIMT2aComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as,"CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(MicrowaveTrapWittCost);
            _isMicrowaveTrapUnlocked = true;
            GameVars.Values.HasBoughtMicrowaveTrap = _isMicrowaveTrapUnlocked;
            OnUpgrade?.Invoke();
        }
    }
    public void UnlockSlowTrap()
    {
        if(!_isSlowTrapUnlocked && _inventory.HasEnoughWitts(SlowTrapWittCost))
        {
            HandleUISTUnlockComponents();
            EnableUIST1aComponents();
            EnableUIST2aComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(SlowTrapWittCost);
            _isSlowTrapUnlocked = true;
            GameVars.Values.HasBoughtSlowingTrap = _isSlowTrapUnlocked;
            OnUpgrade?.Invoke();
        }
    }
    public void UnlockElectricTrap()
    {
        if(!_isElectricTrapUnlocked && _inventory.HasEnoughWitts(ElectricTrapWittCost))
        {
            HandleUIETUnlockComponents();
            EnableUIET1aComponents();
            EnableUIET2aComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ElectricTrapWittCost);
            _isElectricTrapUnlocked = true;
            GameVars.Values.HasBoughtElectricTrap = _isElectricTrapUnlocked;
            OnUpgrade?.Invoke();
        } 
    }
    public void UnlockPaintballMinigunTrap()
    {
        if(!_isPaintballMinigunTrapUnlocked && _inventory.HasEnoughWitts(PaintballMinigunTrapWittCost))
        {
            HandleUIFPMUnlockComponents();
            EnableUIFPM1aComponents();
            EnableUIFPM2aComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(PaintballMinigunTrapWittCost);
            _isPaintballMinigunTrapUnlocked = true;
            GameVars.Values.HasBoughtPaintballMinigunTrap = _isPaintballMinigunTrapUnlocked;
            OnUpgrade?.Invoke();
        }
        
    }

    public void UpgradeBaseballLauncher1a()
    {
        if(!_isBL1aActivated && _inventory.HasEnoughWitts(BL1aWittCost))
        {
            HandleUIBL2aComponents(true, false, 0.2196078f);
            HandleUIBL2bComponents(true, false, 0.2196078f);
            HandleUIBL1aComponents(false,false, 0.2196078f);
            EnableUIBL1bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(BL1aWittCost);
            _isBL1aActivated = true;
            OnUpgrade?.Invoke();
        }
        
    }
    public void UpgradeBaseballLauncher1b()
    {
        if (!_isBL1bActivated && _inventory.HasEnoughWitts(BL1bWittCost))
        {
            HandleUIBL1bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(BL1bWittCost);
            _isBL1bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeBaseballLauncher2a()
    {
        if(!_isBL2aActivated && _inventory.HasEnoughWitts(BL2aWittCost))
        {
            HandleUIBL1aComponents(true, false, 0.2196078f);
            HandleUIBL1bComponents(true, false, 0.2196078f);
            HandleUIBL2aComponents(false, false, 0.2196078f);
            EnableUIBL2bComponents();  
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(BL2aWittCost);
            _isBL2aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeBaseballLauncher2b()
    {
        if (!_isBL2bActivated && _inventory.HasEnoughWitts(BL2bWittCost))
        {
            HandleUIBL2bComponents(false,false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(BL2bWittCost);
            _isBL2bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeFERNPaintballMinigun1a()
    {
        if(!_isFPM1aActivated && _isPaintballMinigunTrapUnlocked && _inventory.HasEnoughWitts(FPM1aWittCost))
        {
            HandleUIFPM1aComponents(false, false, 0.2196078f);
            HandleUIFPM2aComponents(true, false, 0.2196078f);
            HandleUIFPM2bComponents(true, false, 0.2196078f);
            EnableUIFPM1bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(FPM1aWittCost);
            _isFPM1aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeFERNPaintballMinigun1b()
    {
        if (!_isFPM1bActivated && _isPaintballMinigunTrapUnlocked && _inventory.HasEnoughWitts(FPM1bWittCost))
        {
            HandleUIFPM1bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(FPM1bWittCost);
            _isFPM1bActivated = true;
            OnUpgrade?.Invoke();
        }
    }


    public void UpgradeFERNPaintballMinigun2a()
    {
        if(!_isFPM2aActivated && _isPaintballMinigunTrapUnlocked && _inventory.HasEnoughWitts(FPM2aWittCost))
        {
            HandleUIFPM1aComponents(true, false, 0.2196078f);
            HandleUIFPM1bComponents(true, false, 0.2196078f);
            HandleUIFPM2aComponents(false, false, 0.2196078f);
            EnableUIFPM2bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(FPM2aWittCost);
            _isFPM2aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeFERNPaintballMinigun2b()
    {
        if (!_isFPM2bActivated && _isPaintballMinigunTrapUnlocked && _inventory.HasEnoughWitts(FPM2bWittCost))
        {
            HandleUIFPM2bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(FPM2bWittCost);
            _isFPM2bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeElectricTrap1a()
    {
        if(!_isET1aActivated && _isElectricTrapUnlocked && _inventory.HasEnoughWitts(ET1aWittCost))
        {
            HandleUIET1aComponents(false, false, 0.2196078f);
            HandleUIET2aComponents(true, false, 0.2196078f);
            HandleUIET2bComponents(true, false, 0.2196078f);
            EnableUIET1bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ET1aWittCost);
            _isET1aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeElectricTrap1b()
    {
        if (!_isET1bActivated && _isElectricTrapUnlocked && _inventory.HasEnoughWitts(ET1bWittCost))
        {
            HandleUIET1bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ET1bWittCost);
            _isET1bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeElectricTrap2a()
    {
        if(!_isET2aActivated && _isElectricTrapUnlocked && _inventory.HasEnoughWitts(ET2aWittCost))
        {
            HandleUIET1aComponents(true, false, 0.2196078f);
            HandleUIET1bComponents(true, false, 0.2196078f);
            HandleUIET2aComponents(false, false, 0.2196078f);
            EnableUIET2bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ET2aWittCost);
            _isET2aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeElectricTrap2b()
    {
        if (!_isET2bActivated && _isElectricTrapUnlocked && _inventory.HasEnoughWitts(ET2bWittCost))
        {
            HandleUIET2bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ET2bWittCost);
            _isET2bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeSlowTrap1a()
    {
        if(!_isST1aActivated && _isSlowTrapUnlocked && _inventory.HasEnoughWitts(ST1aWittCost))
        {
            HandleUIST2aComponents(true, false, 0.2196078f);
            HandleUIST2bComponents(true, false, 0.2196078f);
            HandleUIST1aComponents(false, false, 0.2196078f);
            EnableUIST1bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ST1aWittCost);
            _isST1aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeSlowTrap1b()
    {
        if (!_isST1bActivated && _isSlowTrapUnlocked && _inventory.HasEnoughWitts(ST1bWittCost))
        {
            HandleUIST1bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ST1bWittCost);
            _isST1bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeSlowTrap2a()
    {
        if(!_isST2aActivated && _isSlowTrapUnlocked && _inventory.HasEnoughWitts(ST2aWittCost))
        {
            HandleUIST1aComponents(true, false, 0.2196078f);
            HandleUIST1bComponents(true, false, 0.2196078f);
            HandleUIST2aComponents(false, false, 0.2196078f);
            EnableUIST2bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ST2aWittCost);
            _isST2aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeSlowTrap2b()
    {
        if (!_isST2bActivated && _isSlowTrapUnlocked && _inventory.HasEnoughWitts(ST2bWittCost))
        {
            HandleUIST2bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(ST2bWittCost);
            _isST2bActivated = true;
            OnUpgrade?.Invoke();
        }
    }

    public void UpgradeMicrowaveTrap1a()
    {
        if(!_isMT1aActivated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT1aWittCost))
        {
            HandleUIMT2aComponents(true, false, 0.2196078f);
            HandleUIMT2bComponents(true, false, 0.2196078f);
            HandleUIMT1aComponents(false, false, 0.2196078f);
            EnableUIMT1bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(MT1aWittCost);
            _isMT1aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeMicrowaveTrap1b()
    {
        if (!_isMT1bActivated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT1bWittCost))
        {
            HandleUIMT1bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(MT1bWittCost);
            _isMT1bActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeMicrowaveTrap2a()
    {
        if(!_isMT2aActivated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT2aWittCost))
        {
            HandleUIMT1aComponents(true, false, 0.2196078f);
            HandleUIMT1bComponents(true, false, 0.2196078f);
            HandleUIMT2aComponents(false, false, 0.2196078f);
            EnableUIMT2bComponents();
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(MT2aWittCost);
            _isMT2aActivated = true;
            OnUpgrade?.Invoke();
        }
    }
    public void UpgradeMicrowaveTrap2b()
    {
        if (!_isMT2bActivated && _isMicrowaveTrapUnlocked && _inventory.HasEnoughWitts(MT2bWittCost))
        {
            HandleUIMT2bComponents(false, false, 0.2196078f);
            GameVars.Values.soundManager.PlaySoundOnce(_as, "CoinSFX", soundVolume, false);
            _inventory.RemoveWitts(MT2bWittCost);
            _isMT2bActivated = true;
            OnUpgrade?.Invoke();
        }
    }



    #endregion
}
