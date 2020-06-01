//
//  main.swift
//  Filesize
//
//  Created by olivier PIERI on 09/04/2020.
//  Copyright © 2020 olivier PIERI. All rights reserved.
//

import Foundation
import ImageIO



// Structure to store voume per year
var volumePerYear = [String: Int64]()

// variable to store the biggest file
var biggestFile: String = ""
var biggestSize: Int64 = 0


//----------------------------------------------------------------------------------------------------------------------------------------
// function to calculate the biggest pict
//----------------------------------------------------------------------------------------------------------------------------------------
func CalcBig (mDir: String) {
    do {
           let fileManager = FileManager.default
           let files = try fileManager.contentsOfDirectory(atPath: mDir)
           
           // for each file in the folder
           for f in files {
               // if it is a folder, go to the child folder
               var isDir : ObjCBool = false
               if fileManager.fileExists(atPath: mDir + "/" + f , isDirectory: &isDir) {
               if isDir.boolValue {
                   PrintCount()
                   CalcBig (mDir: mDir + "/" + f)
               }
                   
               // else, it is a file
               else {
                   let fileextension = NSURL(fileURLWithPath: mDir + "/" + f).pathExtension?.uppercased()
                   
                   // if the extension is an image
                   if fileextension == "PSD" || fileextension == "NEF" || fileextension == "3FR" || fileextension == "CR2" || fileextension == "DNG" || fileextension == "JPEG" || fileextension == "JPG" || fileextension == "PSB" || fileextension == "RAF" || fileextension == "TIF" {
                   
                       let fileattr = try fileManager.attributesOfItem(atPath: mDir + "/" + f)
                       
                       // take the image size
                       let filesize = fileattr[FileAttributeKey.size] as! Int64
                    
                    if filesize > biggestSize {
                        biggestSize = filesize
                        biggestFile = mDir + "/" + f
                    }
                }
                }
            }
        }
    }
    catch {
               print (error.localizedDescription)
           }
}


//----------------------------------------------------------------------------------------------------------------------------------------
// function to calculate volume of image per year
//----------------------------------------------------------------------------------------------------------------------------------------
func CalcSize (mDir: String) {
  
    // Compteur to count number of image

    
    
    do {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: mDir)
        
        // for each file in the folder
        for f in files {
            // if it is a folder, go to the child folder
            var isDir : ObjCBool = false
            if fileManager.fileExists(atPath: mDir + "/" + f , isDirectory: &isDir) {
            if isDir.boolValue {
                PrintCount()
                CalcSize (mDir: mDir + "/" + f)
            }
                
            // else, it is a file
            else {
                let fileextension = NSURL(fileURLWithPath: mDir + "/" + f).pathExtension?.uppercased()
                
                // if the extension is an image
                if fileextension == "PSD" || fileextension == "NEF" || fileextension == "3FR" || fileextension == "CR2" || fileextension == "DNG" || fileextension == "JPEG" || fileextension == "JPG" || fileextension == "PSB" || fileextension == "RAF" || fileextension == "TIF" {
                
                    let fileattr = try fileManager.attributesOfItem(atPath: mDir + "/" + f)
                    
                    // take the image size
                    let filesize = fileattr[FileAttributeKey.size] as! Int64
                    
                    let UrlPath = URL(fileURLWithPath: mDir + "/" + f)
                    
                    // open the metadata part of the image
                    let imageSource = CGImageSourceCreateWithURL(UrlPath as CFURL, nil)
                    let result = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as Dictionary?
                    if result != nil {
                        
                        let d = result as! [AnyHashable:Any]
              
                        // open the exif part of the metadata
                        let tiffDict = d["{Exif}"]
                        
                        //if the exif part exists
                        if tiffDict != nil {
                            let tiffDictSwift = tiffDict as! [AnyHashable:Any]
                            
                            // take the "DateTimeOriginal" in the exif
                            if tiffDictSwift["DateTimeOriginal"] != nil {
                                
                                // take only the year in the date
                                let datecreate = tiffDictSwift["DateTimeOriginal"] as! String
                                let start = datecreate.index(datecreate.startIndex, offsetBy: 0)
                                let end = datecreate.index(datecreate.startIndex, offsetBy: 3)
                                let range = start...end
                        
                                let year = String(datecreate[range])
                                
                                //if we have no data for the year, put the size for this new year
                                if volumePerYear[year] == nil {
                                    volumePerYear[year] = filesize
                                }
                                    
                                // else, increment the size for the year
                                else {
                                    volumePerYear[year]! += filesize
                                }
                            }
                        }
                    }
                    
                }
                
                //print (mDir + "/" +, countStyle: <#T##ByteCountFormatter.CountStyle#>) , year )
            }
            
        }
    }
    }
        
        catch {
            print (error.localizedDescription)
        }
}



//----------------------------------------------------------------------------------------------------------------------------------------
// function to extract all the exif for each image
//----------------------------------------------------------------------------------------------------------------------------------------
func CalcStat(mDir: String) {
   
    PrintCount()
    
    do {
        // Create the file to store the result and store the header
        let statFileManager = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
        let statFileName = statFileManager[0].appendingPathComponent("statPict.csv")
       
        //create a file manager to read all the file image
          let fileManager = FileManager.default
          let files = try fileManager.contentsOfDirectory(atPath: mDir)
          
          // for each file in the folder
          for f in files {
              // if it is a folder, go to the child folder
              var isDir : ObjCBool = false
              if fileManager.fileExists(atPath: mDir + "/" + f , isDirectory: &isDir) {
              if isDir.boolValue {
                PrintCount()
                  CalcStat (mDir: mDir + "/" + f)
              }
                  
              // else, it is a file
              else {
                  let fileextension = NSURL(fileURLWithPath: mDir + "/" + f).pathExtension?.uppercased()
                  
                  // if the extension is an image
                  if fileextension == "NEF" || fileextension == "DNG" || fileextension == "3FR" || fileextension == "CR2" {
                    let UrlPath = URL(fileURLWithPath: mDir + "/" + f)
                       
                    // open the metadata part of the image
                    let imageSource = CGImageSourceCreateWithURL(UrlPath as CFURL, nil)
                    let result = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as Dictionary?
                    if result != nil {
                
                        let d = result as! [AnyHashable:Any]
                        let ExifDict = d["{Exif}"] as! [AnyHashable:Any]
                        let TiffDict = d["{TIFF}"] as! [AnyHashable:Any]
                        var lensmodel: String = ""
                        if fileextension == "NEF" || fileextension == "DNG" || fileextension == "CR2" {
                            let ExifAuxDict = d["{ExifAux}"] as! [AnyHashable:Any]
                            if ExifAuxDict["LensModel"] != nil {
                                lensmodel = ExifAuxDict["LensModel"] as! String
                            }
                        }
                        
                        //take only the year and month from the date
                        var stat: String = ""
                        if  ExifDict["DateTimeOriginal"] != nil {
                            let datecreate = ExifDict["DateTimeOriginal"] as! String
                            let start = datecreate.index(datecreate.startIndex, offsetBy: 0)
                            let end = datecreate.index(datecreate.startIndex, offsetBy: 10)
                            let range = start...end
                            let replaced = datecreate[range].replacingOccurrences(of: ":", with: "-")
                                                        
                            stat += replaced
                            stat += ","
                            
                            let startyear = datecreate.index(datecreate.startIndex, offsetBy: 0)
                            let endyear = datecreate.index(datecreate.startIndex, offsetBy: 3)
                            let rangeyear = startyear...endyear
                            stat += replaced[rangeyear]
                            stat += ","
                            
                            let startmonth = datecreate.index(datecreate.startIndex, offsetBy: 5)
                            let endmonth = datecreate.index(datecreate.startIndex, offsetBy: 6)
                            let rangemonth = startmonth...endmonth
                            stat += replaced[rangemonth]
                            
                            
                        }
                        stat += ","
                        stat += TiffDict["Make"] as! String
                        stat += ","
                        stat += TiffDict["Model"] as! String
                        stat += ","
                        if fileextension == "NEF" || fileextension == "DNG" || fileextension == "CR2" {
                                stat += lensmodel
                        }
                        
                        // take the aperture and convert it to a string
                        stat += ","
                        if ExifDict["FNumber"] != nil {
                            let f = ExifDict["FNumber"] as! NSNumber
                            stat += "f" + f.stringValue
                        }
                        stat += ","
                        
                        // take the Iso and convert it to a string as it is stored in an array
                        if ExifDict["ISOSpeedRatings"] != nil {
                            let iso = ExifDict["ISOSpeedRatings"] as! [NSNumber]
                            let i = iso[0].stringValue
                            stat += "ISO" + i
                        }
                        stat += ","
                        
                        // take the shutter speed and convert it to a readable string
                        if ExifDict["ExposureTime"] != nil {
                            let s = ExifDict["ExposureTime"] as! NSNumber
                            let speedString = FormatSpeed(speed: s)
                            stat += speedString
                        }
                        
                        stat += ","
                        if ExifDict["FocalLength"] != nil {
                            let focale = ExifDict["FocalLength"] as! NSNumber
                            stat += focale.stringValue
                        }
                        stat += "\n"
                        // write the metadata to the file
                         do {
                            let fileHandle = try FileHandle(forWritingTo: statFileName)
                            fileHandle.seekToEndOfFile()
                            
                            fileHandle.write(stat.data(using: String.Encoding.utf8)!)
                             fileHandle.closeFile()
                               }
                               catch {
                                   print (error.localizedDescription)
                               }

                    }
                }
            }
        }
           
     }
    }
        
            catch {
                     print (error.localizedDescription)
                 }

}



//----------------------------------------------------------------------------------------------------------------------------------------
// Convert the shutter speed in a string to be more readable
//----------------------------------------------------------------------------------------------------------------------------------------
func FormatSpeed (speed: NSNumber) -> String {
    let speedFormatString: String
    let s = speed as! Double
    let speedround = Double(floor(10000*s)/10000)
    
    
    switch speedround {
    case 30:
        speedFormatString = "30''"
    case 25:
        speedFormatString = "25''"
    case 20:
        speedFormatString = "20''"
    case 15:
        speedFormatString = "15''"
    case 13:
        speedFormatString = "13''"
    case 10:
        speedFormatString = "10''"
    case 8:
        speedFormatString = "8''"
    case 6:
        speedFormatString = "6''"
    case 5:
        speedFormatString = "5''"
    case 4:
        speedFormatString = "4''"
    case 3:
        speedFormatString = "3''"
    case 2.5:
        speedFormatString = "2.5''"
    case 2:
        speedFormatString = "2''"
    case 1.6:
        speedFormatString = "1.6''"
    case 1.3:
        speedFormatString = "1.3''"
    case 1:
        speedFormatString = "1''"
    case 0.7692:
        speedFormatString = "1/1.3"
    case 0.625:
        speedFormatString = "1/1.6"
    case 0.5:
        speedFormatString = "1/2"
    case 0.4:
        speedFormatString = "1/2.5"
    case 0.3333:
        speedFormatString = "1/3"
    case 0.25:
        speedFormatString = "1/4"
    case 0.2:
        speedFormatString = "1/5"
    case 0.1666:
        speedFormatString = "1/6"
    case 0.125:
        speedFormatString = "1/8"
    case 0.1:
        speedFormatString = "1/10"
    case 0.0769:
        speedFormatString = "1/13"
    case 0.0666:
        speedFormatString = "1/15"
    case 0.05:
        speedFormatString = "1/20"
    case 0.04:
        speedFormatString = "1/25"
    case 0.0333:
        speedFormatString = "1/30"
    case 0.025:
        speedFormatString = "1/40"
    case 0.02:
        speedFormatString = "1/50"
    case 0.0166:
        speedFormatString = "1/60"
    case 0.0125:
        speedFormatString = "1/80"
    case 0.01:
        speedFormatString = "1/100"
    case 0.008:
        speedFormatString = "1/125"
    case 0.0062:
        speedFormatString = "1/160"
    case 0.005:
        speedFormatString = "1/200"
    case 0.004:
        speedFormatString = "1/250"
    case 0.0031:
        speedFormatString = "1/320"
    case 0.0025:
        speedFormatString = "1/400"
    case 0.002:
        speedFormatString = "1/500"
    case 0.0015:
        speedFormatString = "1/640"
    case 0.0012:
        speedFormatString = "1/800"
    case 0.001:
        speedFormatString = "1/1000"
    case 0.0008:
        speedFormatString = "1/1250"
    case 0.0006:
        speedFormatString = "1/1600"
    case 0.0005:
        speedFormatString = "1/2000"
    case 0.0004:
        speedFormatString = "1/2500"
    case 0.0003:
        speedFormatString = "1/3200"
    case 0.0002:
        speedFormatString = "1/4000"
    case 0.0001:
        speedFormatString = "1/8000"
        
    default:
        speedFormatString = String(speedround)
    }
    
    return speedFormatString
}

//----------------------------------------------------------------------------------------------------------------------------------------
// function to print the usage
//----------------------------------------------------------------------------------------------------------------------------------------
func usage() {
    print ("**************************************************")
    print ("USAGE :      FileSize -action Folder             ")
    print (" -action = -vol for volume per year              ")
    print ("    OR                                           ")
    print (" - action = -stat for statistics in file         ")
    print ("    OR                                           ")
    print (" - action = -big for the biggest file            ")
    print ("*************************************************")
    exit(0)
}



//----------------------------------------------------------------------------------------------------------------------------------------
// function to make a progress indicator : TO BE DONE
//----------------------------------------------------------------------------------------------------------------------------------------
func PrintCount() {
    print ("*", terminator:"")
    
    fflush(__stdoutp)
    
}




//----------------------------------------------------------------------------------------------------------------------------------------
//         MAIN
//----------------------------------------------------------------------------------------------------------------------------------------
let arguments = CommandLine.arguments

if arguments.count != 3 {
    usage()
}

let action = arguments[1]
let masterDir = arguments[2]


//let masterDir = "/Volumes/Olivier/Original/Paysage/Voyage US/Zion"
let fileManager = FileManager.default
if !fileManager.fileExists(atPath: masterDir) {
    print ("Directory does not exists")
    exit(0)
}


switch action {
case "-vol":
    print("*******************************************************************")
    print("***           Start Calculating Volume Data per year            ***")
    print("*******************************************************************")
    CalcSize (mDir: masterDir)
    
    for (y, vol) in volumePerYear.sorted(by: { $0.key < $1.key }){
        let volPrintable = ByteCountFormatter.string(fromByteCount: vol, countStyle: .file)
        print("\(y), \(volPrintable)")
    }
case "-stat":
    print("*******************************************************************")
    print("***           Start Calculating Statistcs Data                  ***")
    print("*******************************************************************")
    let statFileManager = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
    let statFileName = statFileManager[0].appendingPathComponent("statPict.csv")
    if FileManager.default.fileExists(atPath: statFileName.path) {
        try FileManager.default.removeItem(at: statFileName)
    }
    let header = "Date,Year,Month,Make,Model,LensModel,FNumber,ISO,ExposureTime,Focale\n"
    do {
        try header.write(to: statFileName, atomically: true, encoding: String.Encoding.utf8)
    }
    catch {
        print (error.localizedDescription)
    }
   
    CalcStat (mDir: masterDir)
case "-big":
    print("*******************************************************************")
    print("***               Start Calculating Biggest image               ***")
    print("*******************************************************************")
    
    CalcBig(mDir: masterDir)
    print ("\n the biggest file is :" + biggestFile + " size : " + String(biggestSize))
default:
    usage()
}

print ("\n END !")







