using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelManager : MonoBehaviour
{
    public delegate void LevelDelegate();
    public CraftingRecipe craftingRecipe;
    public bool playing = true;
    public bool inRound = false;
    public Player _player;

    private void Start()
    {
        _player = GameObject.Find("Player").GetComponent<Player>();
        craftingRecipe.RestoreBuildAmount();
    }

    private void Update()
    {
        if (_player.isDead) LoseGame();
    }

    public void EndRound()
    {
        inRound = false;
    }

    public void WinGame()
    {
        Debug.Log("You Win!");
    }

    public void LoseGame()
    {
        playing = false;
        Debug.Log("Loser");
    }
}
