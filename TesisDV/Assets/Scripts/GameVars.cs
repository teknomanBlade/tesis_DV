using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameVars : MonoBehaviour
{
    private static GameVars _gameVars;
    public static GameVars Values { get { return _gameVars; } }

    [SerializeField]
    private string objectLayerName;
    [SerializeField]
    private string floorLayerName;
    [SerializeField]
    private string enemyLayerName;

    // KeyBinds
    public KeyCode jumpKey;
    public KeyCode primaryFire;
    public KeyCode secondaryFire;
    public KeyCode useKey;
    public KeyCode grabKey;
    public KeyCode sprintKey;
    public KeyCode crouchKey;
    public bool crouchToggle;

    //Resources
    public Sprite crosshair;
    public Sprite crosshairDoor;
    public Sprite crosshairHandGrab;

    private void Awake()
    {
        if (_gameVars == null) _gameVars = this;
        else Destroy(this);

        SetKeys();
        LoadResources();
    }

    private void SetKeys()
    {
        jumpKey = KeyCode.Space;
        primaryFire = KeyCode.Mouse0;
        secondaryFire = KeyCode.Mouse1;
        grabKey = KeyCode.E;
        useKey = KeyCode.F;
        sprintKey = KeyCode.LeftShift;
        crouchKey = KeyCode.LeftControl;
        crouchToggle = false;
    }

    private void LoadResources()
    {
        crosshair = Resources.Load<Sprite>("crosshair");
        crosshairDoor = Resources.Load<Sprite>("OpenDoor");
        crosshairHandGrab = Resources.Load<Sprite>("HandGrab");
    }

    public int GetItemLayer()
    {
        return LayerMask.NameToLayer(objectLayerName);
    }

    public LayerMask GetItemLayerMask()
    {
        LayerMask lm = 1 << GetItemLayer();
        return lm;
    }

    public int GetFloorLayer()
    {
        return LayerMask.NameToLayer(floorLayerName);
    }

    public LayerMask GetFloorLayerMask()
    {
        LayerMask lm = 1 << GetFloorLayer();
        return lm;
    }

    public int GetEnemyLayer()
    {
        return LayerMask.NameToLayer(enemyLayerName);
    }

    public LayerMask GetEnemyLayerMask()
    {
        LayerMask lm = 1 << GetEnemyLayer();
        return lm;
    }
}
