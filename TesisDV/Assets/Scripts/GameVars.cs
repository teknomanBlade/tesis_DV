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

    // KeyBinds
    public KeyCode jumpKey;
    public KeyCode primaryFire;
    public KeyCode secondaryFire;
    public KeyCode useKey;
    public KeyCode sprintKey;
    public KeyCode crouchKey;
    public bool crouchToggle;

    private void Awake()
    {
        if (_gameVars == null) _gameVars = this;
        else Destroy(this);

        SetKeys();
    }

    private void SetKeys()
    {
        jumpKey = KeyCode.Space;
        primaryFire = KeyCode.Mouse0;
        secondaryFire = KeyCode.Mouse1;
        useKey = KeyCode.F;
        sprintKey = KeyCode.LeftShift;
        crouchKey = KeyCode.LeftControl;
        crouchToggle = false;
    }

    public int GetObjectLayer()
    {
        return LayerMask.NameToLayer(objectLayerName);
    }

    public LayerMask GetObjectLayerMask()
    {
        LayerMask lm = 1 << GetObjectLayer();
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
}
